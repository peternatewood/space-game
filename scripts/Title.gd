extends Control

onready var loader = get_node("/root/SceneLoader")
onready var mission_data = get_node("/root/MissionData")
onready var options_menu = get_node("Options Menu")
onready var settings = get_node("/root/GlobalSettings")


func _ready():
	var exit_button = get_node("Container/Exit")
	var new_game_button = get_node("Container/New Game")
	var options_button = get_node("Container/Options")

	exit_button.connect("pressed", self, "_on_exit_pressed")
	new_game_button.connect("pressed", self, "_on_new_game_pressed")
	options_button.connect("pressed", self, "_on_options_pressed")

	new_game_button.grab_focus()

	options_menu.connect("back_button_pressed", self, "_on_back_button_pressed")
	settings.connect("dyslexia_toggled", self, "_on_dyslexia_toggled")


func _on_back_button_pressed():
	options_menu.hide()


func _on_dyslexia_toggled(toggled_on: bool):
	if toggled_on:
		set_theme(settings.OPEN_DYSLEXIC_THEME)
	else:
		set_theme(settings.INCONSOLATA_THEME)


func _on_exit_pressed():
	get_tree().quit()


func _on_new_game_pressed():
	mission_data.load_mission_data("res://missions/my_mission.tscn")
	loader.change_scene("res://briefing.tscn")


func _on_options_pressed():
	options_menu.show()
