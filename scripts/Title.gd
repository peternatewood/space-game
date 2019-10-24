extends Control

onready var exit_button = get_node("Container/Exit")
onready var loader = get_node("/root/SceneLoader")
onready var mission_data = get_node("/root/MissionData")
onready var new_game_button = get_node("Container/New Game")


func _ready():
	exit_button.connect("pressed", self, "_on_exit_pressed")
	new_game_button.connect("pressed", self, "_on_new_game_pressed")

	new_game_button.grab_focus()


func _on_new_game_pressed():
	mission_data.load_mission_data("debug_mission")
	loader.change_scene("res://loadout.tscn")


func _on_exit_pressed():
	get_tree().quit()
