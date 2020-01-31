extends Control

onready var add_mission_dialog = get_node("Add Mission Dialog")
onready var add_mission_options = get_node("Add Mission Dialog/Rows/Mission Options")
onready var change_mission_dialog = get_node("Change Mission Dialog")
onready var delete_dialog = get_node("Delete Dialog")
onready var description = get_node("Mission Container/Rows/Description")
onready var title_label = get_node("Mission Container/Rows/Title Label")
onready var mission_options = get_node("Change Mission Dialog/Rows/Mission Options")
onready var next_missions_container = get_node("Next Missions Container")

var mission_path: String


func _ready():
	var move_up_button = get_node("Position Buttons/Move Up Button")
	move_up_button.connect("pressed", self, "_on_move_up_pressed")

	var move_down_button = get_node("Position Buttons/Move Down Button")
	move_down_button.connect("pressed", self, "_on_move_down_pressed")

	change_mission_dialog.connect("confirmed", self, "_on_change_mission_confirmed")

	var change_mission_button = get_node("Mission Container/Rows/Change Mission Button")
	change_mission_button.connect("pressed", change_mission_dialog, "popup_centered")

	var add_mission_button = get_node("Mission Container/Rows/Buttons Container/Add Mission Button")
	add_mission_button.connect("pressed", add_mission_dialog, "popup_centered")

	add_mission_dialog.connect("confirmed", self, "_on_add_mission_confirmed")

	var delete_button = get_node("Mission Container/Rows/Buttons Container/Delete Button")
	delete_button.connect("pressed", delete_dialog, "popup_centered")

	delete_dialog.connect("confirmed", self, "queue_free")


func _on_change_mission_confirmed():
	var mission_index: int = mission_options.get_selected_id()
	emit_signal("mission_changed", mission_index)


func _on_add_mission_confirmed():
	var mission_index: int = add_mission_options.get_selected_id()
	emit_signal("add_mission_confirmed", mission_index)


func _on_add_objective_requirement_pressed(objective_requirement):
	emit_signal("add_objective_requirement_pressed", objective_requirement)


func _on_move_up_pressed():
	emit_signal("move_up_pressed")


func _on_move_down_pressed():
	emit_signal("move_down_pressed")


# PUBLIC


func add_next_mission(mission_index: int, missions_list: Array):
	var next_mission = NEXT_MISSION_NODE.instance()
	next_missions_container.add_child(next_mission)
	next_mission.set_mission_options(mission_index, missions_list)
	next_mission.connect("add_objective_requirement_pressed", self, "_on_add_objective_requirement_pressed")

	return next_mission


func get_data():
	var next_missions: Array = []
	for mission in next_missions_container.get_children():
		next_missions.append(mission.get_data())

	var data: Dictionary = {
		"path": mission_path,
		"next_missions": next_missions
	}

	return data


func set_mission(mission_data: Dictionary):
	mission_path = mission_data.path
	title_label.set_text(mission_data.name)
	description.set_text(mission_data.description)
	delete_dialog.set_title("Delete " + mission_data.name + " mission")


func set_mission_options(missions: Array):
	var index: int = 0
	for m in missions:
		add_mission_options.add_item(m.name, index)
		mission_options.add_item(m.name, index)
		index += 1


signal add_mission_confirmed
signal add_objective_requirement_pressed
signal mission_changed
signal move_up_pressed
signal move_down_pressed

const NEXT_MISSION_NODE = preload("res://editor/prefabs/next_mission_node.tscn")
