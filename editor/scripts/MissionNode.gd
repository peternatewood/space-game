extends Control

onready var change_mission_dialog = get_node("Change Mission Dialog")
onready var description = get_node("Rows/Description")
onready var title_label = get_node("Rows/Title Label")
onready var mission_options = get_node("Change Mission Dialog/Mission Options")

var mission_path: String


func _ready():
	change_mission_dialog.connect("confirmed", self, "_on_change_mission_confirmed")

	var change_mission_button = get_node("Rows/Change Mission Button")
	change_mission_button.connect("pressed", change_mission_dialog, "popup_centered")


func _on_change_mission_confirmed():
	pass


# PUBLIC


func set_mission(path: String, mission_name: String, mission_description: String):
	mission_path = path
	title_label.set_text(mission_name)
	description.set_text(mission_description)
