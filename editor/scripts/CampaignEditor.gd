extends Control

onready var missions_container = get_node("Rows/Missions Panel/Missions Scroll/Missions Container")

var first_mission


func _ready():
	create_new_campaign()


# PUBLIC


func create_new_campaign():
	for row in missions_container.get_children():
		row.queue_free()

	var hbox = HBoxContainer.new()
	missions_container.add_child(hbox)
	hbox.set_alignment(BoxContainer.ALIGN_CENTER)

	first_mission = MISSION_NODE.instance()
	hbox.add_child(first_mission)


const MISSION_NODE = preload("res://editor/prefabs/mission_node.tscn")
