extends Node

enum { NEUTRAL, FRIENDLY, HOSTILE }

onready var loader = get_node("/root/SceneLoader")
onready var mission_data = get_node("/root/MissionData")
onready var pause_menu = get_node("Pause Menu")
onready var player_path: String = get_meta("player_path")
onready var reinforcement_wings: Array = get_meta("reinforcement_wings")

var factions = {
	"frog": { "hawk": FRIENDLY, "spider": NEUTRAL },
	"hawk": { "frog": FRIENDLY, "spider": HOSTILE },
	"spider": { "hawk": HOSTILE, "frog": NEUTRAL }
}
var player
var targets_container
var waypoints: Array = []
var waypoints_container
# TODO: Multiple groups of waypoints that we can assign to npc ships


func _ready():
	loader.connect("scene_loaded", self, "_on_scene_loaded")
	set_process(false)


func _input(event):
	if event.is_action("pause") and event.pressed:
		var tree = get_tree()
		if not tree.paused:
			tree.set_pause(true)
			pause_menu.show()


func _on_main_menu_confirmed():
	loader.load_scene("res://title.tscn")


func _on_player_warped_out():
	loader.change_scene("res://debriefing.tscn")


func _on_scene_loaded():
	targets_container = get_node("Targets Container")
	waypoints_container = get_node_or_null("Waypoints Container")
	if waypoints_container != null:
		waypoints = waypoints_container.get_children()

	# Assign loadouts from mission data to ships in scene
	for wing_index in range(mission_data.wing_loadouts.size()):
		var wing_name = mission_data.wing_names[wing_index]

		for index in range(mission_data.wing_loadouts[wing_index].size()):
			var ship = targets_container.get_node_or_null(wing_name + " " + str(index + 1))

			if ship.get_meta("ship_class") != mission_data.wing_loadouts[wing_index][index].ship_class:
				var ship_instance = mission_data.wing_loadouts[wing_index][index].model.instance()

				# Copy relevant data from ship to new instance
				ship_instance.name = ship.name
				ship_instance.transform = ship.transform
				ship_instance.set_script(ship.get_script())
				ship_instance.hull_hitpoints = ship.hull_hitpoints
				ship_instance.faction = ship.faction
				ship_instance.wing_name = ship.wing_name
				ship_instance.is_warped_in = ship.is_warped_in

				var ship_tree_pos = ship.get_position_in_parent()
				targets_container.remove_child(ship)
				targets_container.add_child(ship_instance)
				targets_container.move_child(ship_instance, ship_tree_pos)

				if ship_instance is Player:
					ship_instance.camera_path = ship.camera_path
				elif ship_instance is NPCShip:
					ship_instance.initial_orders = ship.initial_orders

				ship.free()
				ship = ship_instance

			if ship == null:
				print("No such ship in scene: " + wing_name + " " + str(index + 1))
			else:
				ship.set_weapon_hardpoints(mission_data.get_weapon_models("energy_weapons", wing_index, index), mission_data.get_weapon_models("missile_weapons", wing_index, index))

	# And don't forget the non-player-accessible ships!
	for ship_name in mission_data.non_player_loadouts.keys():
		var ship = targets_container.get_node_or_null(ship_name)
		if ship != null:
			if ship is NPCShip:
				ship.set_weapon_hardpoints(mission_data.non_player_loadouts[ship_name].energy_weapons, mission_data.non_player_loadouts[ship_name].missile_weapons)
			elif ship is CapitalShipBase:
				ship.set_weapon_turrets(mission_data.non_player_loadouts[ship_name].beam_weapons, mission_data.non_player_loadouts[ship_name].energy_weapons, mission_data.non_player_loadouts[ship_name].missile_weapons)
			else:
				print("Invalid node in targets container: " + ship.name)

	player = get_node(player_path)
	player.connect("warped_out", self, "_on_player_warped_out")

	# Prepare mission objectives
	for index in range(mission_data.objectives.size()):
		for objective in mission_data.objectives[index]:
			objective.connect_targets_to_requirements(targets_container)

	pause_menu.connect("main_menu_confirmed", self, "_on_main_menu_confirmed")

	set_process(true)
	emit_signal("mission_ready")

	get_tree().set_pause(true)


# PUBLIC


func get_alignment(factionA: String, factionB: String):
	if factionA == factionB:
		return FRIENDLY

	if factions.has(factionA):
		return factions[factionA].get(factionB, -1)

	return -1


func get_closest_target(ship, targets: Array, only_alignment: int = -1):
	var closest_distance: float = -1
	var closest_index: int = -1

	for index in range(targets.size()):
		if only_alignment != -1:
			var alignment = get_alignment(ship.faction, targets[index].faction)
			if alignment != only_alignment:
				continue

		var distance_squared = (targets[index].transform.origin - ship.transform.origin).length_squared()
		if distance_squared < closest_distance or closest_distance == -1:
			closest_index = index
			closest_distance = distance_squared

	if closest_index == -1:
		# No targets found
		return null

	return targets[closest_index]


func get_commandable_ships(include_warped_out: bool = false):
	var commandable_ships: Array = []

	for target in get_targets(include_warped_out):
		# TODO: also check some other property like rank or ship class to determine whether player can command or not
		if target != player and target is NPCShip and get_alignment(player.faction, target.faction) == FRIENDLY:
			commandable_ships.append(target)

	return commandable_ships


func get_next_waypoint_pos(index: int):
	return waypoints[index].transform.origin


func get_ships_in_wing(wing_name: String, exclude_ship = null, include_warped_out: bool = false):
	var ships: Array = []

	for ship in get_targets(include_warped_out):
		if ship is NPCShip and ship != exclude_ship and ship.wing_name == wing_name:
			ships.append(ship)

	return ships


func get_targets(include_warped_out: bool = false):
	var warped_in_targets: Array = []
	for child in targets_container.get_children():
		if include_warped_out or child.is_warped_in:
			warped_in_targets.append(child)

	return warped_in_targets


func get_targets_by_distance(ship, targets: Array, only_alignment: int = -1):
	var alignment: int
	var pivot: float
	var ordered_targets: Array

	if only_alignment == -1:
		pivot = (ship.transform.origin - targets[0].transform.origin).length_squared()
		ordered_targets = [ targets[0] ]
	else:
		# Find the first target of this alignment
		var found_target: bool = false
		for target in targets:
			if get_alignment(ship.faction, target.faction) == only_alignment:
				pivot = (ship.transform.origin - target.transform.origin).length_squared()
				ordered_targets = [ target ]
				found_target = true
				break

		# In case no targets match this alignment
		if not found_target:
			return []

	var index: int = 1
	for index in range(targets.size()):
		# Skip this target if not the desired alignment
		if only_alignment != -1:
			alignment = get_alignment(ship.faction, targets[index].faction)
			if alignment != only_alignment:
				continue

		var distance_squared = (ship.transform.origin - targets[index].transform.origin).length_squared()
		if distance_squared < pivot:
			ordered_targets.push_front(targets[index])
		else:
			ordered_targets.push_back(targets[index])

	return ordered_targets


signal mission_ready

const CapitalShipBase = preload("CapitalShipBase.gd")
const NPCShip = preload("NPCShip.gd")
const Objective = preload("Objective.gd")
const Player = preload("Player.gd")
