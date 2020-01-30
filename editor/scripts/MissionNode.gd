extends Control

onready var description = get_node("Rows/Description")
onready var title_label = get_node("Rows/Title Label")

var mission_path: String


func set_mission(path: String, mission_name: String, mission_description: String):
	mission_path = path
	title_label.set_text(mission_name)
	description.set_text(mission_description)
