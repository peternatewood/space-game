extends Control

onready var description_edit = get_node("ScrollContainer/VBoxContainer/Description TextEdit")
onready var enabled_checkbox = get_node("ScrollContainer/VBoxContainer/Enabled CheckBox")
onready var failure_rows = get_node("ScrollContainer/VBoxContainer/Failure Rows")
onready var is_critical_checkbox = get_node("ScrollContainer/VBoxContainer/Is Critical CheckBox")
onready var success_rows = get_node("ScrollContainer/VBoxContainer/Success Rows")
onready var title_lineedit = get_node("ScrollContainer/VBoxContainer/Name Row/Name LineEdit")
onready var trigger_rows = get_node("ScrollContainer/VBoxContainer/Trigger Rows")

var index: int = 0
var objective
var objectives: Array = [ [], [], [] ]
var ship_names: Array = []
var type: int = 0


func _ready():
	var add_failure_button = get_node("ScrollContainer/VBoxContainer/Add Failure Button")
	add_failure_button.connect("pressed", self, "_on_add_requirement_pressed", [ "failure" ])

	var add_success_button = get_node("ScrollContainer/VBoxContainer/Add Success Button")
	add_success_button.connect("pressed", self, "_on_add_requirement_pressed", [ "success" ])

	var add_trigger_button = get_node("ScrollContainer/VBoxContainer/Add Trigger Button")
	add_trigger_button.connect("pressed", self, "_on_add_requirement_pressed", [ "trigger" ])


func _on_add_requirement_pressed(category: String):
	objective.add_requirement(category)

	match category:
		"failure":
			add_requirement(category, objective.failure_requirements[objective.failure_requirements.size() - 1])
		"success":
			add_requirement(category, objective.success_requirements[objective.success_requirements.size() - 1])
		"trigger":
			add_requirement(category, objective.trigger_requirements[objective.trigger_requirements.size() - 1])


# PUBLIC


func add_requirement(category: String, requirement_object):
	var requirement = REQUIREMENT.instance()

	match category:
		"failure":
			failure_rows.add_child(requirement)
		"success":
			success_rows.add_child(requirement)
		"trigger":
			trigger_rows.add_child(requirement)

	requirement.update_ship_names(ship_names)
	requirement.populate_fields(requirement_object, objectives)


func get_objective():
	objective.description = description_edit.text
	objective.name = title_lineedit.text
	objective.enabled = enabled_checkbox.pressed
	objective.is_critical = is_critical_checkbox.pressed

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


func populate_fields(objective_object, ship_names: Array = [], new_objectives: Array = [ [], [], [] ]):
	objective = objective_object
	description_edit.set_text(objective_object.description)
	title_lineedit.set_text(objective_object.name)
	enabled_checkbox.set_pressed(objective_object.enabled)
	is_critical_checkbox.set_pressed(objective_object.is_critical)

	objectives = new_objectives
	ship_names = []
	for ship in ship_names:
		ship_names.append(ship.name)

	var failure_index: int = 0
	var failure_count: int = failure_rows.get_child_count()
	for requirement in objective_object.failure_requirements:
		if failure_index < failure_count:
			var failure_requirement = failure_rows.get_child(failure_index)
			failure_requirement.update_ship_names(ship_names)
			failure_requirement.populate_fields(requirement, objectives)
		else:
			add_requirement("failure", requirement)

		failure_index += 1
	# Clean up extra requirement nodes
	for index in range(objective_object.failure_requirements.size(), failure_count):
		failure_rows.get_child(index).queue_free()

	var success_index: int = 0
	var success_count: int = success_rows.get_child_count()
	for requirement in objective_object.success_requirements:
		if success_index < success_count:
			var success_requirement = success_rows.get_child(success_index)
			success_requirement.update_ship_names(ship_names)
			success_requirement.populate_fields(requirement, objectives)
		else:
			add_requirement("success", requirement)

		success_index += 1
	# Clean up extra requirement nodes
	for index in range(objective_object.success_requirements.size(), success_count):
		success_rows.get_child(index).queue_free()

	var trigger_index: int = 0
	var trigger_count: int = trigger_rows.get_child_count()
	for requirement in objective_object.trigger_requirements:
		if trigger_index < trigger_count:
			var trigger_requirement = trigger_rows.get_child(trigger_index)
			trigger_requirement.update_ship_names(ship_names)
			trigger_requirement.populate_fields(requirement, objectives)
		else:
			add_requirement("trigger", requirement)

		trigger_index += 1
	# Clean up extra requirement nodes
	for index in range(objective_object.trigger_requirements.size(), trigger_count):
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


const Objective = preload("res://scripts/Objective.gd")

const REQUIREMENT = preload("res://editor/prefabs/requirement.tscn")
