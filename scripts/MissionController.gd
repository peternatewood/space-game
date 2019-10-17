extends Node

enum { NEUTRAL, FRIENDLY, HOSTILE }

export (NodePath) var player_path

onready var loader = get_node("/root/SceneLoader")

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


func _on_scene_loaded():
	targets_container = get_node("Targets Container")
	waypoints_container = get_node("Waypoints Container")
	waypoints = waypoints_container.get_children()
	player = get_node(player_path)

	set_process(true)


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


func get_commandable_ships():
	var commandable_ships: Array = []

	for target in get_targets():
		# TODO: also check some other property like rank or ship class to determine whether player can command or not
		if target != player and get_alignment(player.faction, target.faction) == FRIENDLY:
			commandable_ships.append(target)

	return commandable_ships


func get_next_waypoint_pos(index: int):
	return waypoints[index].transform.origin


func get_ships_in_wing(wing_name: String, exclude_ship = null):
	var ships: Array = []

	for ship in get_targets():
		if ship != exclude_ship and ship.wing_name == wing_name:
			ships.append(ship)

	return ships


func get_targets():
	var warped_in_targets: Array = []
	for child in targets_container.get_children():
		if child.is_warped_in:
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
