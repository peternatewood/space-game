extends Control

onready var loader = get_node("/root/SceneLoader")
onready var mission_data = get_node("/root/MissionData")
onready var mission_rows = get_node("Mission Select Rows/Missions Panel/Missions")
onready var settings = get_node("/root/GlobalSettings")
onready var user_mission_rows = get_node("Mission Select Rows/User Missions Panel/User Missions")


func _ready():
	# Get mission paths and meta data
	var dir = Directory.new()
	if dir.open("res://missions") != OK:
		print("Unable to open res://missions directory")
	else:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				var mission_path = dir.get_current_dir() + "/" + file_name
				var mission_scene = load(mission_path)
				var mission_instance = mission_scene.instance()

				# Get meta data
				var mission_name = mission_instance.get_meta("name")

				var mission_button = Button.new()
				mission_rows.add_child(mission_button)
				mission_button.set_text(mission_name)
				mission_button.connect("pressed", self, "_on_mission_button_pressed", [ mission_path ])

			file_name = dir.get_next()

	# Get user mission paths and meta data
	dir = Directory.new()
	if dir.open("user://") != OK:
		print("Unable to open user:// directory")
	else:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				var mission_path = dir.get_current_dir() + "/" + file_name
				var mission_scene = load(mission_path)
				var mission_instance = mission_scene.instance()

				# Get meta data
				var mission_name = mission_instance.get_meta("name")

				var mission_button = Button.new()
				user_mission_rows.add_child(mission_button)
				mission_button.set_text(mission_name)
				mission_button.connect("pressed", self, "_on_mission_button_pressed", [ mission_path ])

			file_name = dir.get_next()

	toggle_dyslexia(settings.get_dyslexia())


func _on_mission_button_pressed(mission_path: String):
	mission_data.load_mission_data(mission_path)
	loader.change_scene("res://briefing.tscn")


# PUBLIC


func toggle_dyslexia(toggle_on: bool):
	if toggle_on:
		set_theme(settings.OPEN_DYSLEXIC_INTERFACE_THEME)
	else:
		set_theme(settings.INCONSOLATA_INTERFACE_THEME)
