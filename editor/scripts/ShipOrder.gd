extends Control

onready var priority_spinbox = get_node("Priority SpinBox")
onready var target_options = get_node("Target Options")
onready var type_options = get_node("Type Options")


func get_order_type_index():
	return type_options.get_selected_id()


func set_order(new_order):
	type_options.select(new_order)
