extends Control

onready var priority_spinbox = get_node("Priority SpinBox")
onready var target_options = get_node("Target Options")
onready var type_options = get_node("Type Options")


func get_order():
	var target_name = null
	var target_option_index: int = target_options.get_selected_id()

	if target_option_index != 0:
		target_name = target_options.get_item_text(target_option_index)

	return {
		"priority": priority_spinbox.value,
		"target": target_name,
		"type": type_options.get_selected_id()
	}


func set_order(new_order: Dictionary):
	priority_spinbox.set_value(new_order.priority)
	type_options.select(new_order.type)

	if new_order.target == null:
		target_options.select(0)
	else:
		for index in range(target_options.get_item_count()):
			if target_options.get_item_text(index) == new_order.target:
				target_options.select(index)
				break
