extends Control

onready var mission_name = get_node("Rows/Title Container/Mission Name Label")


func _ready():
	mission_name.set_text(MissionData.mission_name)

	var retry_button = get_node("Rows/Buttons Container/Retry Button")
	retry_button.connect("pressed", self, "_on_retry_pressed")

	# Populate objective containers
	var objective_containers: Array = [
		get_node("Rows/Primary Objectives Container"),
		get_node("Rows/Secondary Objectives Container"),
		get_node("Rows/Secret Objectives Container")
	]

	var mission_complete: bool = true

	for index in range(objective_containers.size()):
		var hide_container: bool = true
		for objective in MissionData.objectives[index]:
			if objective.enabled and (index != Objective.SECRET or objective.state == Objective.COMPLETED):
				if hide_container:
					hide_container = false

				var objective_label = DEBRIEF_OBJECTIVE.instance()
				objective_containers[index].get_node("Objective Rows").add_child(objective_label)
				objective_label.set_props(objective)

			if hide_container:
				objective_containers[index].hide()

			if mission_complete and objective.is_critical and objective.state != Objective.COMPLETED:
				mission_complete = false

	var next_button = get_node("Rows/Buttons Container/Next Button")
	if mission_complete:
		next_button.connect("pressed", self, "_on_next_pressed")
	else:
		next_button.set_disabled(true)

	toggle_dyslexia(GlobalSettings.get_dyslexia())


func _on_next_pressed():
	if MissionData.is_in_campaign:
		var next_mission_path = MissionData.get_next_mission_path()

		if next_mission_path == null:
			SceneLoader.change_scene("res://title.tscn")
		else:
			MissionData.load_mission_data(next_mission_path, true)
			SceneLoader.load_scene("res://briefing.tscn")
	else:
		SceneLoader.change_scene("res://mission_select.tscn")


func _on_retry_pressed():
	MissionData.load_mission_data(MissionData.mission_scene_path)
	SceneLoader.load_scene("res://briefing.tscn")


# PUBLIC


func toggle_dyslexia(toggle_on: bool):
	if toggle_on:
		set_theme(GlobalSettings.OPEN_DYSLEXIC_INTERFACE_THEME)
	else:
		set_theme(GlobalSettings.INCONSOLATA_INTERFACE_THEME)


const Objective = preload("Objective.gd")

const DEBRIEF_OBJECTIVE = preload("res://icons/debrief_objective.tscn")
