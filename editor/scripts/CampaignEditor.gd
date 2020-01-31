extends Control

onready var add_mission_dialog = get_node("Add Mission Dialog")
onready var add_mission_options = get_node("Add Mission Dialog/Rows/Mission Options")
onready var campaign_title = get_node("Rows/Campaign Details/Campaign Title")
onready var campaign_description = get_node("Rows/Campaign Details/Campaign Description")
onready var loader = get_node("/root/SceneLoader")
onready var mission_data = get_node("/root/MissionData")
onready var missions_container = get_node("Rows/Missions Panel/Missions Scroll/Missions Container")
onready var open_dialog = get_node("Open Dialog")
onready var save_dialog = get_node("Save Dialog")

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

	var file_menu = get_node("Rows/Toolbar/Toolbar Columns/File Menu")
	file_menu.get_popup().connect("id_pressed", self, "_on_file_id_pressed")

	open_dialog.connect("file_selected", self, "_on_open_file_selected")
	save_dialog.connect("file_selected", self, "_on_save_file_selected")

	var exit_menu = get_node("Rows/Toolbar/Toolbar Columns/Exit Menu")
	exit_menu.get_popup().connect("id_pressed", self, "_on_exit_id_pressed")

	var add_mission_button = get_node("Rows/Add Mission Button")
	add_mission_button.connect("pressed", add_mission_dialog, "popup_centered")

	add_mission_dialog.connect("confirmed", self, "_on_add_mission_confirmed")

	create_new_campaign(0)


func _on_add_mission_confirmed():
	var mission_index: int = add_mission_options.get_selected_id()
	add_mission_node(mission_index)


func _on_add_objective_requirement_pressed(objective_requirement, mission_index: int):
	objective_requirement.initialize_options(missions_list[mission_index].objectives)


func _on_exit_id_pressed(item_id: int):
	match item_id:
		0:
			loader.change_scene("res://editor/editor.tscn")
		1:
			OS.set_window_title(mission_data.original_title)
			loader.change_scene("res://title.tscn")
		2:
			get_tree().quit()


func _on_file_id_pressed(item_id: int):
	match item_id:
		0:
			create_new_campaign(0)
		1:
			open_dialog.popup_centered()
		2:
			save_dialog.popup_centered()


func _on_mission_node_add_mission_confirmed(mission_index: int, mission_node):
	if not missions_in_campaign.has(mission_index):
		add_mission_node(mission_index)

	mission_node.add_next_mission(mission_index, missions_list)


func _on_mission_node_mission_changed(mission_index: int, mission_node):
	mission_node.set_mission(missions_list[mission_index])


func _on_mission_node_move_up_pressed(mission_node):
	var position: int = mission_node.get_position_in_parent()
	if position > 0:
		missions_container.move_child(mission_node, position - 1)


func _on_mission_node_move_down_pressed(mission_node):
	var position: int = mission_node.get_position_in_parent()
	if position < missions_container.get_child_count() - 1:
		missions_container.move_child(mission_node, position + 1)


func _on_open_file_selected(path: String):
	var campaign_config: ConfigFile = ConfigFile.new()
	if campaign_config.load(path) != OK:
		print("Error opening campaign config file: ", path)
	else:
		# TODO: check that this config file is formatted properly
		var config_name: String = campaign_config.get_value("details", "name", "")
		var config_description: String = campaign_config.get_value("details", "description", "")

		campaign_title.set_text(config_name)
		campaign_description.set_text(config_description)

		# Clear any existing missions
		for mission_node in missions_container.get_children():
			mission_node.queue_free()

		var missions_list_size: int = missions_list.size()
		for mission in campaign_config.get_value("mission_tree", "missions", []):
			var mission_index: int = -1

			for index in range(missions_list_size):
				if missions_list[index].path == mission.path:
					mission_index = index
					break

			if mission_index == -1:
				print("Mission path not found: ", mission.path)
			else:
				var mission_node = add_mission_node(mission_index)
				for next_mission_data in mission.next_missions:
					var next_mission = mission_node.add_next_mission(next_mission_data.index, missions_list)
					for objective_data in next_mission_data.objectives:
						var objective_requirement = next_mission.add_objective_requirement()
						objective_requirement.initialize_options(missions_list[mission_index].objectives)
						objective_requirement.set_options(objective_data.objective_type, objective_data.objective_index)

		OS.set_window_title(mission_data.original_title + SUB_TITLE + config_name)


func _on_save_file_selected(path: String):
	var missions: Array = []

	for mission in missions_container.get_children():
		missions.append(mission.get_data())

	var campaign_config: ConfigFile = ConfigFile.new()
	campaign_config.set_value("details", "name", campaign_title.text)
	campaign_config.set_value("details", "description", campaign_description.text)
	campaign_config.set_value("mission_tree", "missions", missions)
	campaign_config.save(path)

	OS.set_window_title(mission_data.original_title + SUB_TITLE + campaign_title.text)


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
	mission_node.connect("move_up_pressed", self, "_on_mission_node_move_up_pressed", [mission_node])
	mission_node.connect("move_down_pressed", self, "_on_mission_node_move_down_pressed", [mission_node])

	return mission_node


func create_new_campaign(first_mission_index: int):
	OS.set_window_title(mission_data.original_title + SUB_TITLE + "untitled")

	campaign_title.set_text("")
	campaign_description.set_text("")

	for row in missions_container.get_children():
		row.queue_free()

	add_mission_node(first_mission_index)


const MISSION_NODE = preload("res://editor/prefabs/mission_node.tscn")
const SUB_TITLE: String = " Campaign Editor: "
