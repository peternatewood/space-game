extends Control

onready var mission_data = get_node("/root/MissionData")
onready var mission_name = get_node("Rows/Title Container/Mission Name Label")


func _ready():
	mission_name.set_text(mission_data.mission_name)

	# Populate objective containers
	var objective_containers: Array = [
		get_node("Rows/Primary Objectives Container"),
		get_node("Rows/Secondary Objectives Container"),
		get_node("Rows/Secret Objectives Container")
	]

	for index in range(objective_containers.size()):
		if mission_data.objectives[index].size() == 0:
			objective_containers[index].hide()
		else:
			for objective in mission_data.objectives[index]:
				var objective_label = DEBRIEF_OBJECTIVE.instance()
				objective_containers[index].get_node("Objective Rows").add_child(objective_label)
				objective_label.set_props(objective)


const DEBRIEF_OBJECTIVE = preload("res://icons/debrief_objective.tscn")
