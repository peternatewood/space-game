extends Control

onready var name_label = get_node("Name Label")

var objective
var type: int


func _ready():
	var delete_button = get_node("Delete Button")
	delete_button.connect("pressed", self, "_on_delete_button_pressed")

	var edit_button = get_node("Edit Button")
	edit_button.connect("pressed", self, "_on_edit_button_pressed")


func _on_delete_button_pressed():
	emit_signal("delete_button_pressed", objective, type, get_position_in_parent())
	queue_free()


func _on_edit_button_pressed():
	emit_signal("edit_button_pressed", objective, type, get_position_in_parent())


# PUBLIC


func set_objective(source_dictionary: Dictionary):
	objective = Objective.new(source_dictionary)
	set_objective_name(objective.name)


func set_objective_name(objective_name: String):
	if objective_name == "":
		objective_name = "--"

	name_label.set_text(objective_name)


func update_objective(new_objective: Objective):
	objective = new_objective
	set_objective_name(objective.name)


signal delete_button_pressed
signal edit_button_pressed

const Objective = preload("res://scripts/Objective.gd")
