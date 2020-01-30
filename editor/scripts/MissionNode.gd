extends Control

onready var add_mission_dialog = get_node("Add Mission Dialog")
onready var add_mission_options = get_node("Add Mission Dialog/Rows/Mission Options")
onready var change_mission_dialog = get_node("Change Mission Dialog")
onready var description = get_node("Rows/Description")
onready var title_label = get_node("Rows/Title Label")
onready var mission_options = get_node("Change Mission Dialog/Rows/Mission Options")

var mission_path: String


func _ready():
	change_mission_dialog.connect("confirmed", self, "_on_change_mission_confirmed")

	var change_mission_button = get_node("Rows/Change Mission Button")
	change_mission_button.connect("pressed", change_mission_dialog, "popup_centered")

	var add_mission_button = get_node("Rows/Buttons Container/Add Mission Button")
	add_mission_button.connect("pressed", add_mission_dialog, "popup_centered")

	add_mission_dialog.connect("confirmed", self, "_on_add_mission_confirmed")


func _on_change_mission_confirmed():
	var mission_index: int = mission_options.get_selected_id()
	emit_signal("mission_changed", mission_index)


func _on_add_mission_confirmed():
	var mission_index: int = add_mission_options.get_selected_id()
	emit_signal("add_mission_confirmed", mission_index)


# PUBLIC


func set_mission(mission_data: Dictionary):
	mission_path = mission_data.path
	title_label.set_text(mission_data.name)
	description.set_text(mission_data.description)


func set_mission_options(missions: Array):
	var index: int = 0
	for m in missions:
		add_mission_options.add_item(m.name, index)
		mission_options.add_item(m.name, index)
		index += 1


signal add_mission_confirmed
signal mission_changed
