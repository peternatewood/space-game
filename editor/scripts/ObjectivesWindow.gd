extends Control

onready var objective_rows: Array = [
	get_node("Objectives Window Rows/Primary Panel/Primary Rows/Primary Objectives"),
	get_node("Objectives Window Rows/Secondary Panel/Secondary Rows/Secondary Objectives"),
	get_node("Objectives Window Rows/Secret Panel/Secret Rows/Secret Objectives")
]


func _on_edit_button_pressed(objective, type, index):
	emit_signal("edit_button_pressed", objective, type, index)


# PUBLIC


func prepare_objectives(objectives: Array):
	for type in range(min(objective_rows.size(), objectives.size())):
		var index: int = 0

		for objective_data in objectives[type]:
			var objective_item = OBJECTIVE.instance()
			objective_rows[type].add_child(objective_item)

			objective_item.set_objective(objective_data)
			objective_item.connect("edit_button_pressed", self, "_on_edit_button_pressed", [ type, index ])

			index += 1


func update_objective(type: int, index: int, objective):
	objective_rows[type].get_child(index).update_objective(objective)


signal edit_button_pressed

const OBJECTIVE = preload("res://editor/prefabs/objective.tscn")
