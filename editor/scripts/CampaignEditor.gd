extends Control

onready var mission_data = get_node("/root/MissionData")
onready var missions_container = get_node("Rows/Missions Panel/Missions Scroll/Missions Container")

var first_mission
var missions_list: Array = []


func _ready():
	var missions_directory: Directory = Directory.new()
	if missions_directory.open(mission_data.USER_MISSIONS_DIR) != OK:
		print("Unable to open user missions directory! ", mission_data.USER_MISSIONS_DIR)
	else:
		missions_directory.list_dir_begin()
		var file_name = missions_directory.get_next()
		while file_name != "":
			file_name = missions_directory.get_next()
			if not missions_directory.current_is_dir() and file_name.ends_with(".tscn"):
				var path: String = mission_data.USER_MISSIONS_DIR + "/" + file_name
				var mission_scene = load(path)
				var mission_instance = mission_scene.instance()

				var file_data: Dictionary = {
					"name": "name",
					"description": "<no description>",
					"path": path
				}
				if mission_instance.has_meta("name"):
					file_data.name = mission_instance.get_meta("name")
				else:
					print("Mission " + file_name + " missing name!")
				if mission_instance.has_meta("description"):
					file_data.description = mission_instance.get_meta("description")
				else:
					print("Mission " + file_name + " missing description!")

				missions_list.append(file_data)

	create_new_campaign(0)


# PUBLIC


func add_mission_node(hbox, mission_index: int):
	var mission_node = MISSION_NODE.instance()
	hbox.add_child(mission_node)
	mission_node.set_mission(missions_list[mission_index])
	mission_node.set_mission_options(missions_list)

	return mission_node


func create_new_campaign(first_mission_index: int):
	for row in missions_container.get_children():
		row.queue_free()

	var hbox = HBoxContainer.new()
	missions_container.add_child(hbox)
	hbox.set_alignment(BoxContainer.ALIGN_CENTER)

	first_mission = add_mission_node(hbox, first_mission_index)

const MISSION_NODE = preload("res://editor/prefabs/mission_node.tscn")
