extends Control

onready var primary_options = get_node("Primary Option")
onready var secondary_options = get_node("Secondary Option")
onready var secret_options = get_node("Secret Option")
onready var type_option = get_node("Type Option")


func _ready():
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


# PUBLIC


func set_objective_options(objectives: Array):
	var primary_count: int = objectives[Objective.PRIMARY].size()
	if primary_count == 0:
		type_option.set_item_disabled(Objective.PRIMARY, true)
	else:
		type_option.set_item_disabled(Objective.PRIMARY, false)

		for index in range(primary_count):
			primary_options.add_item(objectives[Objective.PRIMARY][index].name, index)

	var secondary_count: int = objectives[Objective.SECONDARY].size()
	if secondary_count == 0:
		type_option.set_item_disabled(Objective.SECONDARY, true)
	else:
		type_option.set_item_disabled(Objective.SECONDARY, false)

		for index in range(secondary_count):
			secondary_options.add_item(objectives[Objective.SECONDARY][index].name, index)

	var secret_count: int = objectives[Objective.SECRET].size()
	if secret_count == 0:
		type_option.set_item_disabled(Objective.SECRET, true)
	else:
		type_option.set_item_disabled(Objective.SECRET, false)

		for index in range(secret_count):
			secret_options.add_item(objectives[Objective.SECRET][index].name, index)

	if type_option.is_item_disabled(type_option.get_selected_id()):
		for option_index in range(type_option.get_item_count()):
			if not type_option.is_item_disabled(option_index):
				type_option.select(option_index)
				break


const Objective = preload("res://scripts/Objective.gd")
