extends Control

onready var name_label = get_node("Name Label")

var objective setget set_objective


func set_objective(source_dictionary: Dictionary):
	objective = Objective.new(source_dictionary)
	name_label.set_text(objective.name)


const Objective = preload("res://scripts/Objective.gd")
