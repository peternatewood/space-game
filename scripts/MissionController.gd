extends Node

onready var loader = get_node("/root/SceneLoader")

var factions = {
	"frog": { "hawk": FRIENDLY, "spider": NEUTRAL },
	"hawk": { "frog": FRIENDLY, "spider": HOSTILE },
	"spider": { "hawk": HOSTILE, "frog": NEUTRAL }
}


func _ready():
	loader.connect("scene_loaded", self, "_on_scene_loaded")
	set_process(false)


func _on_scene_loaded():
	set_process(true)


# PUBLIC


func get_alignment(factionA: String, factionB: String):
	if factions.has_key(factionA):
		return factions[factionA].get(factionB, -1)

	return -1


enum { NEUTRAL, FRIENDLY, HOSTILE }
