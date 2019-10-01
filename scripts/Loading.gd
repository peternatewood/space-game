extends Control

onready var spinner = get_node("Spinner")


func _process(delta):
	var rotation_degrees = spinner.rect_rotation + delta * SPINNER_SPEED
	spinner.set_rotation_degrees(rotation_degrees)


const SPINNER_SPEED: float = 320.0
