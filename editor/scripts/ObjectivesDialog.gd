extends Control

onready var description_edit = get_node("ScrollContainer/VBoxContainer/Description TextEdit")
onready var failure_rows = get_node("ScrollContainer/VBoxContainer/Failure Rows")
onready var success_rows = get_node("ScrollContainer/VBoxContainer/Success Rows")
onready var title_lineedit = get_node("ScrollContainer/VBoxContainer/Name Row/Name LineEdit")
onready var trigger_rows = get_node("ScrollContainer/VBoxContainer/Trigger Rows")

var ship_names: Array = []


func add_requirement(type: String, requirement_data):
	var requirement = REQUIREMENT.instance()
	print(type)

	match type:
		"failure":
			failure_rows.add_child(requirement)
		"success":
			success_rows.add_child(requirement)
		"trigger":
			trigger_rows.add_child(requirement)

	requirement.ship_names = ship_names
	requirement.populate_fields(requirement_data)


func populate_fields(data):
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
