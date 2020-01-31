extends Control

onready var objective_options: Array = [
	get_node("Primary Option"),
	get_node("Secondary Option"),
	get_node("Secret Option")
]
onready var type_option = get_node("Type Option")


func _ready():
	type_option.connect("item_selected", self, "_on_type_selected")


func _on_type_selected(item_id: int):
	match item_id:
		Objective.PRIMARY:
			objective_options[Objective.PRIMARY].show()
			objective_options[Objective.SECONDARY].hide()
			objective_options[Objective.SECRET].hide()
		Objective.SECONDARY:
			objective_options[Objective.PRIMARY].hide()
			objective_options[Objective.SECONDARY].show()
			objective_options[Objective.SECRET].hide()
		Objective.SECRET:
			objective_options[Objective.PRIMARY].hide()
			objective_options[Objective.SECONDARY].hide()
			objective_options[Objective.SECRET].show()


# PUBLIC


func get_data():
	var objective_type: int = type_option.get_selected_id()
	var data: Dictionary = {
		"objective_type": objective_type,
		"objective_index": objective_options[objective_type].get_selected_id()
	}

	return data


func initialize_options(objectives: Array):
	for index in range(objectives.size()):
		var objective_count: int = objectives[index].size()
		if objective_count == 0:
			type_option.set_item_disabled(index, true)
		else:
			type_option.set_item_disabled(index, false)

			for objective_index in range(objective_count):
				objective_options[index].add_item(objectives[index][objective_index].name, index)

	if type_option.is_item_disabled(type_option.get_selected_id()):
		for option_index in range(type_option.get_item_count()):
			if not type_option.is_item_disabled(option_index):
				type_option.select(option_index)
				break


func set_options(type: int, index: int):
	type_option.select(type)
	objective_options[type].select(index)


const Objective = preload("res://scripts/Objective.gd")
