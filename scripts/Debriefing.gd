extends Control

onready var loader = get_node("/root/SceneLoader")
onready var mission_data = get_node("/root/MissionData")
onready var mission_name = get_node("Rows/Title Container/Mission Name Label")
onready var settings = get_node("/root/GlobalSettings")


func _ready():
	mission_name.set_text(mission_data.mission_name)

	var next_button = get_node("Rows/Buttons Container/Next Button")
	var retry_button = get_node("Rows/Buttons Container/Retry Button")

	next_button.connect("pressed", self, "_on_next_pressed")
	retry_button.connect("pressed", self, "_on_retry_pressed")

	# Populate objective containers
	var objective_containers: Array = [
		get_node("Rows/Primary Objectives Container"),
		get_node("Rows/Secondary Objectives Container"),
		get_node("Rows/Secret Objectives Container")
	]

	for index in range(objective_containers.size()):
		var hide_container: bool = true
		for objective in mission_data.objectives[index]:
			if objective.enabled and (index != objective.SECRET or objective.state == objective.COMPLETED):
				if hide_container:
					hide_container = false

				var objective_label = DEBRIEF_OBJECTIVE.instance()
				objective_containers[index].get_node("Objective Rows").add_child(objective_label)
				objective_label.set_props(objective)

			if hide_container:
				objective_containers[index].hide()

	toggle_dyslexia(settings.get_dyslexia())


func _on_next_pressed():
	if mission_data.is_in_campaign:
		var next_mission_path = mission_data.get_next_mission_path()

		if next_mission_path == null:
			loader.load_scene("res://title.tscn")
		else:
			mission_data.load_mission_data(next_mission_path, true)
			loader.load_scene("res://briefing.tscn")
	else:
		loader.load_scene("res://mission_select.tscn")


func _on_retry_pressed():
	mission_data.load_mission_data(mission_data.mission_scene_path)
	loader.load_scene("res://briefing.tscn")


# PUBLIC


func toggle_dyslexia(toggle_on: bool):
	if toggle_on:
		set_theme(settings.OPEN_DYSLEXIC_INTERFACE_THEME)
	else:
		set_theme(settings.INCONSOLATA_INTERFACE_THEME)


const DEBRIEF_OBJECTIVE = preload("res://icons/debrief_objective.tscn")
