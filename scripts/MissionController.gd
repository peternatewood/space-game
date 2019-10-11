extends Node

onready var loader = get_node("/root/SceneLoader")

var factions = {
	"frog": { "hawk": FRIENDLY, "spider": NEUTRAL },
	"hawk": { "frog": FRIENDLY, "spider": HOSTILE },
	"spider": { "hawk": HOSTILE, "frog": NEUTRAL }
}
var targets: Array


func _ready():
	loader.connect("scene_loaded", self, "_on_scene_loaded")
	set_process(false)


func _on_scene_loaded():
	targets = get_node("Targets Container").get_children()
	targets.append(get_node("Player"))

	for index in range(targets.size()):
		targets[index].connect("destroyed", self, "_on_ship_destroyed", [ index ])

	set_process(true)


func _on_ship_destroyed(index: int):
	targets.remove(index)


# PUBLIC


func get_alignment(factionA: String, factionB: String):
	if factionA == factionB:
		return FRIENDLY

	if factions.has(factionA):
		return factions[factionA].get(factionB, -1)

	return -1


enum { NEUTRAL, FRIENDLY, HOSTILE }
