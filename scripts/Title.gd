extends Control

onready var eyecatch_timer = get_node("Eyecatch Timer")
onready var options_menu = get_node("Options Menu")


func _ready():
	var change_profile_button = get_node("Container/Change Profile")
	var continue_campaign_button = get_node("Container/Continue Campaign")
	var database_button = get_node("Container/Database")
	var exit_button = get_node("Container/Exit")
	var mission_editor_button = get_node("Container/Mission Editor")
	var mission_select_button = get_node("Container/Mission Select")
	var new_campaign_button = get_node("Container/New Campaign")
	var options_button = get_node("Container/Options")

	if MissionData.has_profile_started_campaign():
		continue_campaign_button.set_disabled(false)
		continue_campaign_button.connect("pressed", self, "_on_continue_campaign_pressed")
		continue_campaign_button.grab_focus()
	else:
		new_campaign_button.grab_focus()

	change_profile_button.connect("pressed", self, "_on_change_profile_pressed")
	database_button.connect("pressed", self, "_on_database_pressed")
	exit_button.connect("pressed", self, "_on_exit_pressed")
	mission_editor_button.connect("pressed", self, "_on_mission_editor_pressed")
	mission_select_button.connect("pressed", self, "_on_mission_select_pressed")
	new_campaign_button.connect("pressed", self, "_on_new_campaign_pressed")
	options_button.connect("pressed", self, "_on_options_pressed")

	options_menu.connect("back_button_pressed", self, "_on_back_button_pressed")

	toggle_dyslexia(GlobalSettings.get_dyslexia())
	GlobalSettings.connect("dyslexia_toggled", self, "toggle_dyslexia")

	eyecatch_timer.connect("timeout", self, "_on_eyecatch_timeout")
	eyecatch_timer.start()


func _input(event):
	eyecatch_timer.start()


func _on_back_button_pressed():
	options_menu.hide()


func _on_change_profile_pressed():
	SceneLoader.change_scene("res://profiles.tscn")


func _on_continue_campaign_pressed():
	MissionData.load_current_profile_mission()
	SceneLoader.load_scene("res://briefing.tscn")


func _on_database_pressed():
	SceneLoader.change_scene("res://database.tscn")


func _on_exit_pressed():
	get_tree().quit()


func _on_eyecatch_timeout():
	MissionData.load_mission_data("res://eyecatch.tscn")
	SceneLoader.load_scene("res://eyecatch.tscn")


func _on_mission_editor_pressed():
	SceneLoader.load_scene("res://editor/editor.tscn")


func _on_mission_select_pressed():
	SceneLoader.change_scene("res://mission_select.tscn")


func _on_new_campaign_pressed():
	SceneLoader.change_scene("res://campaign_select.tscn")


func _on_options_pressed():
	options_menu.show()


# PUBLIC


func toggle_dyslexia(toggled_on: bool):
	if toggled_on:
		set_theme(GlobalSettings.OPEN_DYSLEXIC_THEME)
	else:
		set_theme(GlobalSettings.INCONSOLATA_THEME)
