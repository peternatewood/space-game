extends Control

onready var new_game_button = get_node("Container/New Game")
onready var exit_button = get_node("Container/Exit")


func _ready():
	new_game_button.connect("pressed", self, "_on_new_game_pressed")
	exit_button.connect("pressed", self, "_on_exit_pressed")


func _on_new_game_pressed():
	get_tree().change_scene("res://mission.tscn")


func _on_exit_pressed():
	get_tree().quit()
