extends Node

onready var loader = get_node("/root/SceneLoader")


func _ready():
	loader.connect("scene_loaded", self, "_on_scene_loaded")
	set_process(false)


func _on_scene_loaded():
	set_process(true)
