extends Control

onready var objective_rows: Array = [
	get_node("Objectives Window Rows/Primary Panel/Primary Rows/Primary Objectives"),
	get_node("Objectives Window Rows/Secondary Panel/Secondary Rows/Secondary Objectives"),
	get_node("Objectives Window Rows/Secret Panel/Secret Rows/Secret Objectives")
]


func _on_edit_button_pressed(objective):
	emit_signal("edit_button_pressed", objective)


# PUBLIC


func prepare_objectives(objectives: Array):
	for index in range(min(objective_rows.size(), objectives.size())):
		for objective_data in objectives[index]:
			var objective_item = OBJECTIVE.instance()
			objective_rows[index].add_child(objective_item)

			objective_item.set_objective(objective_data)
			objective_item.connect("edit_button_pressed", self, "_on_edit_button_pressed")


signal edit_button_pressed

const OBJECTIVE = preload("res://editor/prefabs/objective.tscn")
