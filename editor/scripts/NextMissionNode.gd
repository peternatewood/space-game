extends Control

onready var mission_option = get_node("Rows/Columns/Mission Option")
onready var objective_rows =  get_node("Rows/Objective Rows")


func _ready():
	var add_objective_requirement_button = get_node("Rows/Add Objective Requirement Button")
	add_objective_requirement_button.connect("pressed", self, "_on_add_objective_requirement_pressed")

	var delete_button = get_node("Rows/Columns/Delete Button")
	delete_button.connect("pressed", self, "queue_free")


func _on_add_objective_requirement_pressed():
	var objective_requirement = add_objective_requirement()
	emit_signal("add_objective_requirement_pressed", objective_requirement)


# PUBLIC


func add_objective_requirement():
	var objective_requirement = OBJECTIVE_REQUIREMENT_NODE.instance()
	objective_rows.add_child(objective_requirement)

	return objective_requirement


func get_data():
	var objectives: Array = []
	for objective_requirement in objective_rows.get_children():
		objectives.append(objective_requirement.get_data())

	var data: Dictionary = {
		"index": mission_option.get_selected_id(),
		"objectives": objectives
	}

	return data


func set_mission_options(mission_index: int, missions: Array):
	for index in range(missions.size()):
		mission_option.add_item(missions[index].name, mission_index)

	mission_option.select(mission_index)


signal add_objective_requirement_pressed

const OBJECTIVE_REQUIREMENT_NODE = preload("res://editor/prefabs/objective_requirement_node.tscn")
