extends Control

onready var exit_button = get_node("Container/Exit")
onready var loader = get_node("/root/SceneLoader")
onready var new_game_button = get_node("Container/New Game")


func _ready():
	exit_button.connect("pressed", self, "_on_exit_pressed")
	new_game_button.connect("pressed", self, "_on_new_game_pressed")


func _on_new_game_pressed():
	loader.change_scene("res://mission.tscn")


func _on_exit_pressed():
	get_tree().quit()
