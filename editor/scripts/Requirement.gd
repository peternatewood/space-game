extends Control

onready var add_target_button = get_node("Add Target Button")
onready var objective_label = get_node("Requirement Grid/Objective Label")
onready var objective_options = get_node("Requirement Grid/Objective Options")
onready var objective_type_label = get_node("Requirement Grid/Objective Type Label")
onready var objective_type_options = get_node("Requirement Grid/Objective Type Options")
onready var target_rows = get_node("Targets Rows")
onready var targets_label = get_node("Targets Label")
onready var type_options = get_node("Requirement Grid/Type Options")
onready var waypoint_label = get_node("Requirement Grid/Waypoints Label")
onready var waypoint_options = get_node("Requirement Grid/Waypoints Options")

var objectives: Array = [ [], [], [] ]
var requirement
var ship_names: Array = []


func _ready():
	add_target_button.connect("pressed", self, "_on_add_target_pressed")
	objective_options.connect("item_selected", self, "_on_objective_changed")
	objective_type_options.connect("item_selected", self, "_on_objective_type_changed")
	type_options.connect("item_selected", self, "_on_type_changed")

	var delete_button = get_node("Delete Button")
	delete_button.connect("pressed", self, "queue_free")


func _on_add_target_pressed():
	add_target()


func _on_objective_changed(item_index: int):
	requirement.objective_index = item_index - 1


func _on_objective_type_changed(item_index: int):
	# -1 corresponds to "none", but this is an index so "none" is 0 in our options button
	requirement.objective_type = item_index - 1
	update_objective_fields()


func _on_type_changed(item_index: int):
	# Toggle options based on objective type
	if item_index == Objective.PATROL:
		waypoint_label.show()
		waypoint_options.show()
	else:
		waypoint_label.hide()
		waypoint_options.hide()

	if item_index == Objective.OBJECTIVE:
		objective_label.show()
		objective_options.show()
		objective_type_label.show()
		objective_type_options.show()
	else:
		objective_label.hide()
		objective_options.hide()
		objective_type_label.hide()
		objective_type_options.hide()

	match item_index:
		Objective.PATROL, Objective.OBJECTIVE:
			target_rows.hide()
			targets_label.hide()
			add_target_button.hide()
		_:
			target_rows.show()
			targets_label.show()
			add_target_button.show()


# PUBLIC


func add_target(name: String = ""):
	var target = REQUIREMENT_TARGET.instance()
	target_rows.add_child(target)
	target.populate_options(ship_names)
	target.select_name(name)


func get_requirement():
	requirement.type = type_options.get_selected_id()

	var target_names: Array = []
	for target in target_rows.get_children():
		target_names.append(target.get_name())

	requirement.target_names = target_names

	return requirement


func populate_fields(requirement_object, new_objectives: Array = [ [], [], [] ]):
	objectives = new_objectives
	requirement = requirement_object
	type_options.select(requirement_object.type)
	_on_type_changed(requirement_object.type)

	# Add one because the first is "none" which should correspond to -1 in the Requirement
	objective_type_options.select(requirement.objective_type + 1)

	# Set objective options
	update_objective_fields()

	# Add one because the first is "none" which should correspond to -1 in the Requirement
	objective_options.select(requirement_object.objective_index + 1)

	# Update target options
	var target_index: int = 0
	var target_count = target_rows.get_child_count()
	for name in requirement_object.target_names:
		if target_index < target_count:
			var target = target_rows.get_child(target_index)
			target.select_name(name)
		else:
			add_target(name)

		target_index += 1


func update_objective_fields():
	var objective_index: int = 1
	var selected_index = objective_type_options.get_selected_id()

	# Add objectives to the list if type is not "none"
	if selected_index != 0:
		for objective in objectives[selected_index - 1]:
			if objective_options.get_item_count() <= objective_index:
				objective_options.add_item(objective.name, objective_index)
			else:
				objective_options.set_item_text(objective_index, objective.name)

			objective_index += 1

	# Remove extras
	var objective_item_count: int = objective_options.get_item_count()
	if objective_item_count >= objective_index:
		for index in range(objective_index, objective_item_count):
			objective_options.remove_item(index)


func update_ship_names(new_ship_names: Array):
	ship_names = new_ship_names
	for target in target_rows.get_children():
		target.populate_options(ship_names)


const Objective = preload("res://scripts/Objective.gd")

const REQUIREMENT_TARGET = preload("res://editor/prefabs/requirement_target.tscn")
