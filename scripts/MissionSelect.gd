extends Control

onready var mission_rows = get_node("MarginContainer/Mission Select Rows/Missions Panel/Missions Scroll/Missions")
onready var user_mission_rows = get_node("MarginContainer/Mission Select Rows/User Missions Panel/User Missions Scroll/User Missions")


func _ready():
	# Get mission paths and meta data
	var default_mission_paths: Array = MissionData.get_unlocked_missions()
	if default_mission_paths.size() == 0:
		var none_label = Label.new()
		mission_rows.add_child(none_label)
		none_label.set_text("<none>")
		mission_rows.set_tooltip("Begin a campaign to unlock its missions")
	else:
		for mission_path in default_mission_paths:
			var mission_scene = load(mission_path)
			var mission_instance = mission_scene.instance()

			# Get meta data
			var mission_name = mission_instance.get_meta("name")

			var mission_button = Button.new()
			mission_rows.add_child(mission_button)
			mission_button.set_text(mission_name)
			mission_button.connect("pressed", self, "_on_mission_button_pressed", [ mission_path ])

	# Get user mission paths and meta data
	var user_mission_count: int = 0
	var dir = Directory.new()
	dir = Directory.new()
	if dir.open(MissionData.USER_MISSIONS_DIR) != OK:
		print("Unable to open user://missions directory")
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

				user_mission_count += 1

			file_name = dir.get_next()

	if user_mission_count == 0:
		var none_label = Label.new()
		user_mission_rows.add_child(none_label)
		none_label.set_text("<none>")
		user_mission_rows.set_tooltip("Create your own missions\nin the Mission Editor")

	toggle_dyslexia(GlobalSettings.get_dyslexia())

	var back_button = get_node("MarginContainer/Mission Select Rows/Back Button")
	back_button.connect("pressed", self, "_on_back_pressed")


func _on_back_pressed():
	SceneLoader.change_scene("res://title.tscn")


func _on_mission_button_pressed(mission_path: String):
	MissionData.load_mission_data(mission_path)
	MissionData.is_in_campaign = false
	SceneLoader.load_scene("res://briefing.tscn")


# PUBLIC


func toggle_dyslexia(toggle_on: bool):
	if toggle_on:
		set_theme(GlobalSettings.OPEN_DYSLEXIC_INTERFACE_THEME)
	else:
		set_theme(GlobalSettings.INCONSOLATA_INTERFACE_THEME)
