extends Control

onready var mission_controller = get_node("/root/Mission Controller")

var mission_ready: bool = false


func _ready():
	if mission_controller != null:
		mission_controller.connect("mission_ready", self, "_on_mission_ready")


func _input(event):
	if mission_ready and event is InputEventKey and event.scancode == KEY_ESCAPE and event.pressed:
		accept_event()
		get_tree().set_pause(false)
		queue_free()


func _on_mission_ready():
	mission_ready = true
