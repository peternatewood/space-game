extends Node

onready var loader = get_node("/root/SceneLoader")

var factions = {
	"frog": { "hawk": FRIENDLY, "spider": NEUTRAL },
	"hawk": { "frog": FRIENDLY, "spider": HOSTILE },
	"spider": { "hawk": HOSTILE, "frog": NEUTRAL }
}
var targets_container


func _ready():
	loader.connect("scene_loaded", self, "_on_scene_loaded")
	set_process(false)


func _on_scene_loaded():
	targets_container = get_node("Targets Container")
	set_process(true)


# PUBLIC


func get_alignment(factionA: String, factionB: String):
	if factionA == factionB:
		return FRIENDLY

	if factions.has(factionA):
		return factions[factionA].get(factionB, -1)

	return -1


func get_targets():
	return targets_container.get_children()


enum { NEUTRAL, FRIENDLY, HOSTILE }
