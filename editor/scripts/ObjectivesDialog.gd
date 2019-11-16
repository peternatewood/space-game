extends Control

onready var description_edit = get_node("ScrollContainer/VBoxContainer/Description TextEdit")
onready var failure_rows = get_node("ScrollContainer/VBoxContainer/Failure Rows")
onready var success_rows = get_node("ScrollContainer/VBoxContainer/Success Rows")
onready var title_lineedit = get_node("ScrollContainer/VBoxContainer/Name Row/Name LineEdit")
onready var trigger_rows = get_node("ScrollContainer/VBoxContainer/Trigger Rows")

var index: int = 0
var objective
var ship_names: Array = []
var type: int = 0


func add_requirement(type: String, requirement_data):
	var requirement = REQUIREMENT.instance()

	match type:
		"failure":
			failure_rows.add_child(requirement)
		"success":
			success_rows.add_child(requirement)
		"trigger":
			trigger_rows.add_child(requirement)

	requirement.ship_names = ship_names
	requirement.populate_fields(requirement_data)


func get_objective():
	objective.description = description_edit.text
	objective.name = title_lineedit.text

	var failure_requirements: Array = []
	for requirement in failure_rows.get_children():
		failure_requirements.append(requirement.get_requirement())

	objective.failure_requirements = failure_requirements

	var success_requirements: Array = []
	for requirement in success_rows.get_children():
		success_requirements.append(requirement.get_requirement())

	objective.success_requirements = success_requirements

	var trigger_requirements: Array = []
	for requirement in trigger_rows.get_children():
		trigger_requirements.append(requirement.get_requirement())

	objective.trigger_requirements = trigger_requirements

	return objective


func populate_fields(data):
	objective = data
	description_edit.set_text(data.description)
	title_lineedit.set_text(data.name)

	var failure_index: int = 0
	var failure_count: int = failure_rows.get_child_count()
	for requirement in data.failure_requirements:
		if failure_index < failure_count:
			var failure_requirement = failure_rows.get_child(failure_index)
			failure_requirement.populate_fields(requirement)
		else:
			add_requirement("failure", requirement)

		failure_index += 1
	# Clean up extra requirement nodes
	for index in range(data.failure_requirements.size(), failure_count):
		failure_rows.get_child(index).queue_free()

	var success_index: int = 0
	var success_count: int = success_rows.get_child_count()
	for requirement in data.success_requirements:
		if success_index < success_count:
			var success_requirement = success_rows.get_child(success_index)
			success_requirement.populate_fields(requirement)
		else:
			add_requirement("success", requirement)

		success_index += 1
	# Clean up extra requirement nodes
	for index in range(data.success_requirements.size(), success_count):
		success_rows.get_child(index).queue_free()

	var trigger_index: int = 0
	var trigger_count: int = trigger_rows.get_child_count()
	for requirement in data.trigger_requirements:
		if trigger_index < trigger_count:
			var trigger_requirement = trigger_rows.get_child(trigger_index)
			trigger_requirement.populate_fields(requirement)
		else:
			add_requirement("trigger", requirement)

		trigger_index += 1
	# Clean up extra requirement nodes
	for index in range(data.trigger_requirements.size(), trigger_count):
		trigger_rows.get_child(index).queue_free()


func update_ship_names(ships: Array):
	ship_names = []
	for ship in ships:
		ship_names.append(ship.name)

	for requirement in failure_rows.get_children():
		requirement.update_ships(ship_names)

	for requirement in success_rows.get_children():
		requirement.update_ships(ship_names)

	for requirement in trigger_rows.get_children():
		requirement.update_ships(ship_names)


const REQUIREMENT = preload("res://editor/prefabs/requirement.tscn")
