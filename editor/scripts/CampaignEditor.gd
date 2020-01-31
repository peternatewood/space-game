extends Control

onready var add_mission_dialog = get_node("Add Mission Dialog")
onready var add_mission_options = get_node("Add Mission Dialog/Rows/Mission Options")
onready var mission_data = get_node("/root/MissionData")
onready var missions_container = get_node("Rows/Missions Panel/Missions Scroll/Missions Container")

var first_mission
var missions_in_campaign: Array = []
var missions_list: Array = []


func _ready():
	var missions_directory: Directory = Directory.new()
	if missions_directory.open(mission_data.USER_MISSIONS_DIR) != OK:
		print("Unable to open user missions directory! ", mission_data.USER_MISSIONS_DIR)
	else:
		missions_directory.list_dir_begin()
		var file_name = missions_directory.get_next()
		var mission_index: int = 0
		while file_name != "":
			file_name = missions_directory.get_next()
			if not missions_directory.current_is_dir() and file_name.ends_with(".tscn"):
				var path: String = mission_data.USER_MISSIONS_DIR + "/" + file_name
				var mission_scene = load(path)
				var mission_instance = mission_scene.instance()

				var file_data: Dictionary = {
					"name": "name",
					"description": "<no description>",
					"objectives": [],
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

				var objectives = mission_instance.get_meta("objectives")
				if objectives[0].size() != 0 or objectives[1].size() != 0 or objectives[2].size() != 0:
					file_data.objectives = objectives
				else:
					print("Mission " + file_name + " has no objectives!")

				missions_list.append(file_data)
				add_mission_options.add_item(file_data.name, mission_index)
				mission_index += 1

	var add_mission_button = get_node("Rows/Add Mission Button")
	add_mission_button.connect("pressed", add_mission_dialog, "popup_centered")

	add_mission_dialog.connect("confirmed", self, "_on_add_mission_confirmed")

	create_new_campaign(0)


func _on_add_mission_confirmed():
	var mission_index: int = add_mission_options.get_selected_id()
	add_mission_node(mission_index)


func _on_add_objective_requirement_pressed(objective_requirement, mission_index: int):
	objective_requirement.set_objective_options(missions_list[mission_index].objectives)


func _on_mission_node_add_mission_confirmed(mission_index: int, mission_node):
	if not missions_in_campaign.has(mission_index):
		add_mission_node(mission_index)

	mission_node.add_next_mission(mission_index, missions_list)


func _on_mission_node_mission_changed(mission_index: int, mission_node):
	mission_node.set_mission(missions_list[mission_index])


# PUBLIC


func add_mission_node(mission_index: int):
	missions_in_campaign.append(mission_index)

	var mission_node = MISSION_NODE.instance()
	missions_container.add_child(mission_node)
	mission_node.set_mission(missions_list[mission_index])
	mission_node.set_mission_options(missions_list)
	mission_node.connect("add_mission_confirmed", self, "_on_mission_node_add_mission_confirmed", [mission_node])
	mission_node.connect("add_objective_requirement_pressed", self, "_on_add_objective_requirement_pressed", [mission_index])
	mission_node.connect("mission_changed", self, "_on_mission_node_mission_changed", [mission_node])

	return mission_node


func create_new_campaign(first_mission_index: int):
	for row in missions_container.get_children():
		row.queue_free()

	add_mission_node(first_mission_index)

const MISSION_NODE = preload("res://editor/prefabs/mission_node.tscn")
