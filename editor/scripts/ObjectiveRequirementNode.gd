extends Control

onready var primary_options = get_node("Primary Option")
onready var secondary_options = get_node("Secondary Option")
onready var secret_options = get_node("Secret Option")


func _ready():
	var type_option = get_node("Type Option")
	type_option.connect("item_selected", self, "_on_type_selected")


func _on_type_selected(item_id: int):
	match item_id:
		Objective.PRIMARY:
			primary_options.show()
			secondary_options.hide()
			secret_options.hide()
		Objective.SECONDARY:
			primary_options.hide()
			secondary_options.show()
			secret_options.hide()
		Objective.SECRET:
			primary_options.hide()
			secondary_options.hide()
			secret_options.show()


const Objective = preload("res://scripts/Objective.gd")
