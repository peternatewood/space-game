extends Control

onready var add_objective_buttons: Array = [
	get_node("Objectives Window Rows/Primary Panel/Primary Rows/Primary Label Container/Add Primary Button"),
	get_node("Objectives Window Rows/Secondary Panel/Secondary Rows/Secondary Label Container/Add Secondary Button"),
	get_node("Objectives Window Rows/Secret Panel/Secret Rows/Secret Label Container/Add Secret Button")
]
onready var objective_rows: Array = [
	get_node("Objectives Window Rows/Primary Panel/Primary Rows/Primary Objectives"),
	get_node("Objectives Window Rows/Secondary Panel/Secondary Rows/Secondary Objectives"),
	get_node("Objectives Window Rows/Secret Panel/Secret Rows/Secret Objectives")
]


func _ready():
	var close_button = get_node("Objectives Window Rows/HBoxContainer/Close Button")
	close_button.connect("pressed", self, "hide")

	var type: int = 0
	for button in add_objective_buttons:
		button.connect("pressed", self, "_on_add_objective_pressed", [ type ])
		type += 1


func _on_add_objective_pressed(type: int):
	emit_signal("objective_added", type)


func _on_delete_button_pressed(objective, type, index):
	emit_signal("delete_button_pressed", objective, type, index)


func _on_edit_button_pressed(objective, type, index):
	emit_signal("edit_button_pressed", objective, type, index)


# PUBLIC


func add_objective(objective_data: Dictionary, type: int):
	var objective_item = OBJECTIVE.instance()
	objective_rows[type].add_child(objective_item)

	objective_item.set_objective(objective_data)
	objective_item.type = type
	objective_item.connect("delete_button_pressed", self, "_on_delete_button_pressed")
	objective_item.connect("edit_button_pressed", self, "_on_edit_button_pressed")


func prepare_objectives(objectives: Array):
	for type in range(min(objective_rows.size(), objectives.size())):
		var index: int = 0

		for objective_data in objectives[type]:
			add_objective(objective_data, type)

			index += 1


func update_objective(type: int, index: int, objective):
	objective_rows[type].get_child(index).update_objective(objective)


signal delete_button_pressed
signal edit_button_pressed
signal objective_added

const OBJECTIVE = preload("res://editor/prefabs/objective.tscn")
