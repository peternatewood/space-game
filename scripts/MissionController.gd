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


func get_commandable_ships():
	var commandable_ships: Array = []

	for target in get_targets():
		# TODO: also check some other property like rank or ship class to determine whether player can command or not
		if target != player and get_alignment(player.faction, target.faction) == FRIENDLY:
			commandable_ships.append(target)

	return commandable_ships


func get_next_waypoint_pos(index: int):
	return waypoints[index].transform.origin


func get_targets():
	return targets_container.get_children()

