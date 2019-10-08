extends Control

onready var loader = get_node("/root/SceneLoader")
onready var progress_bar = get_node("Progress Bar")
onready var spinner = get_node("Spinner")


func _ready():
	progress_bar.set_value(0)
	loader.connect("loading_progressed", self, "_update_progress_bar")


func _process(delta):
	var rotation_degrees = spinner.rect_rotation + delta * SPINNER_SPEED
	spinner.set_rotation_degrees(rotation_degrees)


func _update_progress_bar(percent: float):
	progress_bar.set_value(percent)


const SPINNER_SPEED: float = 320.0
