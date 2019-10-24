extends Control

onready var mission_data = get_node("/root/MissionData")
onready var mission_name = get_node("Title Container/Mission Name Label")


func _ready():
	mission_name.set_text(mission_data.mission_name)
