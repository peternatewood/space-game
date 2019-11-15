extends Control

onready var objective_rows: Array = [
	get_node("Objectives Dialog Rows/Primary Panel/Primary Rows/Primary Objectives"),
	get_node("Objectives Dialog Rows/Secondary Panel/Secondary Rows/Secondary Objectives"),
	get_node("Objectives Dialog Rows/Secret Panel/Secret Rows/Secret Objectives")
]


func prepare_objectives(objectives: Array):
	for index in range(min(objective_rows.size(), objectives.size())):
		for objective_data in objectives[index]:
			var objective_item = OBJECTIVE.instance()
			objective_rows[index].add_child(objective_item)
			objective_item.set_objective(objective_data)


const OBJECTIVE = preload("res://editor/objective.tscn")
