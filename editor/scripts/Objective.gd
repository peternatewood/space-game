extends Control

onready var name_label = get_node("Name Label")

var objective setget set_objective


func _ready():
	var edit_button = get_node("Edit Button")
	edit_button.connect("pressed", self, "_on_edit_button_pressed")


func _on_edit_button_pressed():
	emit_signal("edit_button_pressed", objective)


# PUBLIC


func set_objective(source_dictionary: Dictionary):
	objective = Objective.new(source_dictionary)
	name_label.set_text(objective.name)


signal edit_button_pressed

const Objective = preload("res://scripts/Objective.gd")
