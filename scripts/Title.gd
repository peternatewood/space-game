extends Control

onready var loader = get_node("/root/SceneLoader")
onready var mission_data = get_node("/root/MissionData")
onready var options_menu = get_node("Options Menu")
onready var settings = get_node("/root/GlobalSettings")


func _ready():
	var continue_campaign_button = get_node("Container/Continue Campaign")
	var exit_button = get_node("Container/Exit")
	var mission_editor_button = get_node("Container/Mission Editor")
	var mission_select_button = get_node("Container/Mission Select")
	var new_campaign_button = get_node("Container/New Campaign")
	var options_button = get_node("Container/Options")

	continue_campaign_button.connect("pressed", self, "_on_continue_campaign_pressed")
	exit_button.connect("pressed", self, "_on_exit_pressed")
	mission_editor_button.connect("pressed", self, "_on_mission_editor_pressed")
	mission_select_button.connect("pressed", self, "_on_mission_select_pressed")
	new_campaign_button.connect("pressed", self, "_on_new_campaign_pressed")
	options_button.connect("pressed", self, "_on_options_pressed")

	mission_select_button.grab_focus()

	options_menu.connect("back_button_pressed", self, "_on_back_button_pressed")

	toggle_dyslexia(settings.get_dyslexia())
	settings.connect("dyslexia_toggled", self, "toggle_dyslexia")


func _on_back_button_pressed():
	options_menu.hide()


func _on_continue_campaign_pressed():
	mission_data.load_current_profile_mission()
	loader.load_scene("res://briefing.tscn")


func _on_exit_pressed():
	get_tree().quit()


func _on_mission_editor_pressed():
	loader.load_scene("res://editor/editor.tscn")


func _on_mission_select_pressed():
	loader.load_scene("res://mission_select.tscn")


func _on_new_campaign_pressed():
	loader.load_scene("res://campaign_select.tscn")


func _on_options_pressed():
	options_menu.show()


# PUBLIC


func toggle_dyslexia(toggled_on: bool):
	if toggled_on:
		set_theme(settings.OPEN_DYSLEXIC_THEME)
	else:
		set_theme(settings.INCONSOLATA_THEME)
