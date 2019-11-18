extends Spatial

onready var about_window = get_node("Controls Container/About Window")
onready var add_ship_dialog = get_node("Controls Container/Add Ship Dialog")
onready var add_ship_options = get_node("Controls Container/Add Ship Dialog/Add Ship Grid/Ship Class Options")
onready var camera = get_node("Editor Camera")
onready var debug = get_node("Controls Container/Debug")
onready var debug_cube = get_node("Debug")
onready var details_dialog = get_node("Controls Container/Details Dialog")
onready var manipulator_overlay = get_node("Controls Container/Manipulator Overlay")
onready var manipulator_viewport = get_node("Manipulator Viewport")
onready var manual_window = get_node("Controls Container/Manual Window")
onready var mission_data = get_node("/root/MissionData")
onready var mission_node = get_node("Mission Controller")
onready var objectives_edit_dialog = get_node("Controls Container/Objective Edit Dialog")
onready var objectives_window = get_node("Controls Container/Objectives Window")
onready var open_file_dialog = get_node("Controls Container/Open File Dialog")
onready var save_file_dialog = get_node("Controls Container/Save File Dialog")
onready var ship_edit_dialog = get_node("Controls Container/Ship Edit Dialog")
onready var transform_controls = get_node("Manipulator Viewport/Transform Controls")
onready var wings_dialog = get_node("Controls Container/Wings Dialog")

var current_mouse_button: int = -1
var has_player_ship: bool = true
var manipulator_node = null
var default_loadouts: Array = []
var mouse_pos: Vector2
var mouse_vel: Vector2
var objectives: Array = []
var non_player_loadouts: Dictionary
var scene_file_regex = RegEx.new()
var selected_node = null
var selected_node_index: int = -1
var ship_index_name_map: Array = []
var targets_container
var wing_names: Array = []


func _ready():
	get_tree().set_pause(true)

	scene_file_regex.compile("^[\\w\\_\\-]+\\.tscn$")

	load_mission_info()

	var file_menu = get_node("Controls Container/PanelContainer/Toolbar/File Menu")
	file_menu.get_popup().connect("id_pressed", self, "_on_file_menu_id_pressed")

	save_file_dialog.connect("file_selected", self, "_on_save_dialog_file_selected")

	var edit_menu = get_node("Controls Container/PanelContainer/Toolbar/Edit Menu")
	edit_menu.get_popup().connect("id_pressed", self, "_on_edit_menu_id_pressed")

	var mission_menu = get_node("Controls Container/PanelContainer/Toolbar/Mission Menu")
	mission_menu.get_popup().connect("id_pressed", self, "_on_mission_menu_id_pressed")

	var help_menu = get_node("Controls Container/PanelContainer/Toolbar/Help Menu")
	help_menu.get_popup().connect("id_pressed", self, "_on_help_menu_id_pressed")

	open_file_dialog.connect("file_selected", self, "_on_open_file_selected")

	# Get model data from mission_data
	var ship_index: int = 0
	for ship_class in mission_data.ship_models.keys():
		add_ship_options.add_item(ship_class, ship_index)
		ship_index_name_map.append(ship_class)
		ship_index += 1

	for energy_weapon_name in mission_data.energy_weapon_models.keys():
		ship_edit_dialog.energy_weapon_index_name_map.append(energy_weapon_name)

	for missile_weapon_name in mission_data.missile_weapon_models.keys():
		ship_edit_dialog.missile_weapon_index_name_map.append(missile_weapon_name)

	add_ship_dialog.connect("confirmed", self, "_on_add_ship_confirmed")

	# TODO: update manipulator viewport if window size changes
	manipulator_viewport.set_size(get_viewport().size)

	ship_edit_dialog.prepare_options(mission_data)
	ship_edit_dialog.populate_wing_options(wing_names)
	ship_edit_dialog.connect("player_ship_toggled", self, "_on_player_ship_toggled")
	ship_edit_dialog.connect("ship_class_changed", self, "_on_ship_class_changed")
	ship_edit_dialog.connect("ship_energy_weapon_changed", self, "_on_edit_ship_energy_weapon_changed")
	ship_edit_dialog.connect("ship_missile_weapon_changed", self, "_on_edit_ship_missile_weapon_changed")
	ship_edit_dialog.connect("ship_name_changed", self, "_on_edit_ship_name_changed")
	ship_edit_dialog.connect("ship_position_changed", self, "_on_ship_position_changed")
	ship_edit_dialog.connect("ship_wing_changed", self, "_on_ship_wing_changed")

	ship_edit_dialog.previous_button.connect("pressed", self, "_on_edit_dialog_previous_pressed")
	ship_edit_dialog.next_button.connect("pressed", self, "_on_edit_dialog_next_pressed")

	get_node("Controls Container/Viewport Dummy Control").connect("gui_input", self, "_on_controls_gui_input")

	wings_dialog.populate_wing_names(wing_names)
	wings_dialog.connect("confirmed", self, "_on_wings_dialog_confirmed")

	objectives_window.connect("objective_added", self, "_on_objectives_window_objective_added")
	objectives_window.connect("delete_button_pressed", self, "_on_objectives_delete_button_pressed")
	objectives_window.connect("edit_button_pressed", self, "_on_objectives_edit_button_pressed")
	objectives_edit_dialog.connect("confirmed", self, "_on_objectives_dialog_confirmed")

	details_dialog.connect("confirmed", self, "_on_details_dialog_confirmed")


func _on_add_ship_confirmed():
	var ship_class = ship_index_name_map[add_ship_options.get_selected_id()]
	var ship_instance = mission_data.ship_models[ship_class].instance()
	ship_instance.set_script(NPCShip)
	targets_container.add_child(ship_instance)
	non_player_loadouts[ship_instance.name] = {
		"name": ship_instance.name,
		"energy_weapons": [],
		"missile_weapons": []
	}

	for index in range(ship_instance.energy_weapon_hardpoints.size()):
		non_player_loadouts[ship_instance.name].energy_weapons.append("")

	for index in range(ship_instance.missile_weapon_hardpoints.size()):
		non_player_loadouts[ship_instance.name].missile_weapons.append("")


func _on_controls_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			current_mouse_button = event.button_index
		else:
			# TODO: Check which buttons are still pressed, if any
			current_mouse_button = -1

		match event.button_index:
			BUTTON_LEFT:
				if event.pressed:
					# Check manipulator viewport raycast first
					var manipulator_intersect
					if manipulator_overlay.visible:
						manipulator_viewport.update_camera(camera)
						manipulator_intersect = manipulator_viewport.get_node_at_position(event.position)

					if manipulator_intersect != null:
						manipulator_node = manipulator_intersect.collider
					else:
						selected_node = camera.get_node_at_position(event.position)
						selected_node_index = selected_node.get_position_in_parent() if selected_node != null else -1
						manipulator_node = null

						if selected_node != null:
							manipulator_viewport.update_camera(camera)
							transform_controls.toggle(true)
							transform_controls.scale = selected_node.get_meta("cam_distance") * Vector3.ONE
							transform_controls.transform.origin = selected_node.transform.origin
							manipulator_overlay.show()

							var ship_loadout = get_ship_loadout(selected_node)

							ship_edit_dialog.fill_ship_info(selected_node, ship_loadout)
							ship_edit_dialog.show()
						else:
							manipulator_overlay.hide()
							transform_controls.toggle(false)

							ship_edit_dialog.hide()
			BUTTON_WHEEL_UP:
				camera.zoom_in()
				if manipulator_overlay.visible:
					manipulator_viewport.update_camera(camera)
			BUTTON_WHEEL_DOWN:
				camera.zoom_out()
				if manipulator_overlay.visible:
					manipulator_viewport.update_camera(camera)
	elif event is InputEventMouseMotion:
		mouse_pos = event.position
		mouse_vel = event.relative

		match current_mouse_button:
			BUTTON_MIDDLE:
				if event.shift:
					camera.move_position(event.relative)
				else:
					camera.orbit(event.relative)

				if manipulator_overlay.visible:
					manipulator_viewport.update_camera(camera)


func _on_details_dialog_confirmed():
	mission_node.set_meta("name", details_dialog.name_lineedit.text)
	mission_node.set_meta("briefing", [ details_dialog.briefing_textedit.text ])


func _on_edit_dialog_previous_pressed():
	var next_index = (selected_node_index - 1) % targets_container.get_child_count()

	if next_index != selected_node_index:
		selected_node_index = next_index
		selected_node = targets_container.get_child(selected_node_index)
		ship_edit_dialog.fill_ship_info(selected_node, get_ship_loadout(selected_node))


func _on_edit_dialog_next_pressed():
	var next_index = (selected_node_index + 1) % targets_container.get_child_count()

	if next_index != selected_node_index:
		selected_node_index = next_index
		selected_node = targets_container.get_child(selected_node_index)
		ship_edit_dialog.fill_ship_info(selected_node, get_ship_loadout(selected_node))


func _on_edit_menu_id_pressed(item_id: int):
	match item_id:
		0:
			add_ship_dialog.popup_centered()
		1:
			var targets_count = targets_container.get_child_count()
			if targets_count > 0:
				selected_node_index = clamp(selected_node_index, targets_count - 1, 0)
				selected_node = targets_container.get_child(selected_node_index)

				ship_edit_dialog.fill_ship_info(selected_node, get_ship_loadout(selected_node))
				ship_edit_dialog.show()


func _on_mission_menu_id_pressed(item_id: int):
	match item_id:
		0:
			details_dialog.populate_fields(mission_node.get_meta("name"), mission_node.get_meta("briefing"))
			details_dialog.popup_centered()
		1:
			wings_dialog.popup_centered()
		2:
			objectives_window.show()


func _on_edit_ship_energy_weapon_changed(weapon_name: String, slot_index: int):
	var loadout = get_ship_loadout(ship_edit_dialog.edit_ship)
	loadout["energy_weapons"][slot_index] = weapon_name
	set_ship_loadout(ship_edit_dialog.edit_ship, loadout)

	mission_node.set_meta("default_loadouts", default_loadouts)
	mission_node.set_meta("non_player_loadouts", non_player_loadouts)


func _on_edit_ship_missile_weapon_changed(weapon_name: String, slot_index: int):
	var loadout = get_ship_loadout(ship_edit_dialog.edit_ship)
	loadout["missile_weapons"][slot_index] = weapon_name
	set_ship_loadout(ship_edit_dialog.edit_ship, loadout)

	mission_node.set_meta("default_loadouts", default_loadouts)
	mission_node.set_meta("non_player_loadouts", non_player_loadouts)


func _on_edit_ship_name_changed(old_name: String, new_name: String):
	var wing_index: int = get_wing_index(ship_edit_dialog.edit_ship)

	if wing_index == -1:
		var ship_loadout = non_player_loadouts.get(old_name, {})
		non_player_loadouts[new_name] = ship_loadout
		non_player_loadouts.erase(old_name)

		mission_node.set_meta("non_player_loadouts", non_player_loadouts)
	else:
		for loadout in default_loadouts[wing_index]:
			if loadout.name == old_name:
				loadout.name = new_name

				mission_node.set_meta("default_loadouts", default_loadouts)
				return


func _on_file_menu_id_pressed(item_id: int):
	match item_id:
		0:
			var mission_node_name = mission_node.name
			mission_node.free()

			mission_node = DEFAULT_MISSION.instance()
			add_child(mission_node)
			mission_node.set_name(mission_node_name)

			load_mission_info()
		1:
			open_file_dialog.popup_centered()
		2:
			save_file_dialog.popup_centered()
		3:
			get_tree().quit()


func _on_help_menu_id_pressed(item_id: int):
	match item_id:
		0:
			about_window.popup_centered()
		1:
			manual_window.popup_centered()


func _on_objectives_dialog_confirmed():
	var objective = objectives_edit_dialog.get_objective()
	objectives[objectives_edit_dialog.type][objectives_edit_dialog.index] = objective.to_dictionary()
	mission_node.set_meta("objectives", objectives)
	objectives_window.update_objective(objectives_edit_dialog.type, objectives_edit_dialog.index, objective)


func _on_objectives_delete_button_pressed(objective, type, index):
	objectives[type].remove(index)


func _on_objectives_edit_button_pressed(objective, type, index):
	objectives_edit_dialog.type = type
	objectives_edit_dialog.index = index
	objectives_edit_dialog.populate_fields(objective)
	objectives_edit_dialog.popup_centered()


func _on_objectives_window_objective_added(type: int):
	var objective_data = {
		"name": "",
		"description": "",
		"is_critical": type == 0
	}
	objectives[type].append(objective_data)

	objectives_window.add_objective(objective_data, type)


func _on_open_file_selected(path: String):
	if path.ends_with(".tscn"):
		var scene = load(path)

		var mission_node_name = mission_node.name
		mission_node.free()

		mission_node = scene.instance()
		add_child(mission_node)
		mission_node.set_name(mission_node_name)

		load_mission_info()


func _on_player_ship_toggled(is_player_ship: bool):
	if is_player_ship:
		# Ensure we only have one player ship by changing other players to npc ships
		for child in targets_container.get_children():
			if child is Player:
				var ship_data: Dictionary = {
					"hull_hitpoints": child.hull_hitpoints,
					"faction": child.faction,
					"is_warped_in": child.is_warped_in,
					"ship_class": child.ship_class,
					"wing_name": child.wing_name
				}
				child.set_script(NPCShip)

				# Re-apply script properties that will have been lost
				child.hull_hitpoints = ship_data.hull_hitpoints
				child.faction = ship_data.faction
				child.is_warped_in = ship_data.is_warped_in
				child.ship_class = ship_data.ship_class
				child.wing_name = ship_data.wing_name

				# Run _ready again so we get all the onready vars loaded
				child._ready()

	has_player_ship = is_player_ship


func _on_save_dialog_file_selected(path: String):
	if save_file_dialog.current_file.length() == 0:
		print("No file name provided")
	elif scene_file_regex.search(save_file_dialog.current_file) == null:
		print("Invalid file name: " + save_file_dialog.current_file)
	else:
		save_mission_to_file(path)


func _on_ship_class_changed(ship_index: int):
	if ship_index < ship_index_name_map.size():
		var ship_instance = mission_data.ship_models[ship_index_name_map[ship_index]].instance()
		# Copy over all properties from existing ship
		ship_instance.set_script(ship_edit_dialog.edit_ship.get_script())
		ship_instance.hull_hitpoints = ship_edit_dialog.edit_ship.hull_hitpoints
		ship_instance.set_name(ship_edit_dialog.edit_ship.name)
		ship_instance.wing_name = ship_edit_dialog.edit_ship.wing_name

		var ship_transform = ship_edit_dialog.edit_ship.transform

		# This method doesn't seem to work as expected: the old model sticks around
		#ship_edit_dialog.edit_ship.replace_by(ship_instance)

		ship_edit_dialog.edit_ship.free()

		targets_container.add_child(ship_instance)
		ship_instance.transform = ship_transform

		ship_edit_dialog.edit_ship = ship_instance
		selected_node = ship_instance

		# Update loadout for new ship class
		var loadout = get_ship_loadout(ship_instance)

		var energy_weapon_count = ship_instance.energy_weapon_hardpoints.size()
		if energy_weapon_count < loadout.energy_weapons.size():
			for index in range(energy_weapon_count, loadout.energy_weapons.size()):
				loadout.energy_weapons.remove(energy_weapon_count)
		elif energy_weapon_count > loadout.energy_weapons.size():
			for index in range(loadout.energy_weapons.size(), energy_weapon_count):
				loadout.energy_weapons.append("")

		var missile_weapon_count = ship_instance.missile_weapon_hardpoints.size()
		if missile_weapon_count < loadout.missile_weapons.size():
			for index in range(missile_weapon_count, loadout.missile_weapons.size()):
				loadout.missile_weapons.remove(missile_weapon_count)
		elif missile_weapon_count > loadout.missile_weapons.size():
			for index in range(loadout.missile_weapons.size(), missile_weapon_count):
				loadout.missile_weapons.append("")

		set_ship_loadout(ship_instance, loadout)

		mission_node.set_meta("default_loadouts", default_loadouts)
		mission_node.set_meta("non_player_loadouts", non_player_loadouts)
	else:
		print("Invalid ship index selected: " + str(ship_index))


func _on_ship_position_changed(position: Vector3):
	transform_controls.transform.origin = position


func _on_ship_wing_changed(wing_index: int):
	var ship_loadout = get_ship_loadout(ship_edit_dialog.edit_ship)
	if wing_index == -1:
		# Change loadout from default to non_player
		var ship_index: int = 0
		var old_wing_index: int = get_wing_index(ship_edit_dialog.edit_ship)

		# Remove old loadout
		for loadout in default_loadouts[old_wing_index]:
			if loadout.name == ship_edit_dialog.edit_ship.name:
				default_loadouts[old_wing_index].remove(ship_index)
				break
			ship_index += 1

		ship_loadout.erase("name")
		non_player_loadouts[ship_edit_dialog.edit_ship.name] = ship_loadout

		ship_edit_dialog.edit_ship.wing_name = ""
	else:
		if ship_edit_dialog.edit_ship.wing_name == "":
			# Change loadout from non_player to default
			ship_loadout["name"] = ship_edit_dialog.edit_ship.name
			default_loadouts[wing_index].append(ship_loadout)
			non_player_loadouts.erase(ship_edit_dialog.edit_ship.name)

			ship_edit_dialog.edit_ship.wing_name = wing_names[wing_index]
		else:
			# Move loadout to new wing
			default_loadouts[wing_index].append(ship_loadout)

			# Remove old loadout
			var ship_index: int = 0
			var old_wing_index: int = get_wing_index(ship_edit_dialog.edit_ship)
			for loadout in default_loadouts[old_wing_index]:
				if loadout.name == ship_edit_dialog.edit_ship.name:
					default_loadouts[old_wing_index].remove(ship_index)
					break
				ship_index += 1

			ship_edit_dialog.edit_ship.wing_name = wing_names[wing_index]

	print(default_loadouts)
	print(non_player_loadouts)

	mission_node.set_meta("default_loadouts", default_loadouts)
	mission_node.set_meta("non_player_loadouts", non_player_loadouts)


func _on_wings_dialog_confirmed():
	wing_names = wings_dialog.get_wing_names()
	ship_edit_dialog.populate_wing_options(wing_names)

	mission_node.set_meta("wing_names", wing_names)


func _process(delta):
	match current_mouse_button:
		BUTTON_LEFT:
			if selected_node != null and manipulator_node != null:
				# This works but is a little jittery at certain camera angles
				var ray_origin = camera.camera.project_ray_origin(mouse_pos)
				var ray_normal = camera.camera.project_ray_normal(mouse_pos)
				var ray_vector = ray_origin + 100 * ray_normal

				var plane_normal = manipulator_node.transform.basis.y.cross(camera.camera.global_transform.basis.y)

				var w_vector = ray_origin - manipulator_node.global_transform.origin

				# NOTE: If plane_normal.dot(ray_vector) == 0: they're parallel
				var mouse_ray_dot = plane_normal.dot(ray_vector)

				if mouse_ray_dot != 0:
					var w_dot = -plane_normal.dot(w_vector)

					var intersect = ray_origin + (w_dot / mouse_ray_dot) * ray_vector
					var projected_on_up_vector = (intersect - manipulator_node.global_transform.origin).project(manipulator_node.transform.basis.y)

					var translate_vel = projected_on_up_vector - manipulator_node.transform.basis.y

					selected_node.translate(translate_vel)
					transform_controls.transform.origin = selected_node.transform.origin


# PUBLIC


func get_ship_loadout(ship):
	var ship_loadout = {}
	var wing_index: int = get_wing_index(ship)

	if wing_index != -1:
		for loadout in default_loadouts[wing_index]:
			if loadout.name == ship.name:
				return loadout
	else:
		return non_player_loadouts.get(ship.name, {})


func get_wing_index(ship):
	if ship is AttackShipBase and ship.wing_name != "":
		return wing_names.find(ship.wing_name)

	return -1


func load_mission_info():
	targets_container = mission_node.get_node("Targets Container")

	if mission_node.has_meta("default_loadouts"):
		default_loadouts = mission_node.get_meta("default_loadouts")

	if mission_node.has_meta("non_player_loadouts"):
		non_player_loadouts = mission_node.get_meta("non_player_loadouts")

	if mission_node.has_meta("objectives"):
		objectives = mission_node.get_meta("objectives")

	if mission_node.has_meta("wing_names"):
		wing_names = mission_node.get_meta("wing_names")

	objectives_window.prepare_objectives(objectives)
	objectives_edit_dialog.update_ship_names(targets_container.get_children())

	# Reset all other stuff
	ship_edit_dialog.edit_ship = null
	ship_edit_dialog.hide()
	objectives_edit_dialog.hide()
	objectives_window.hide()

	# Hide elements in the mission scene that shouldn't display in the editor
	var hud = mission_node.get_node_or_null("HUD")
	if hud != null:
		hud.hide()

	var start_overlay = mission_node.get_node_or_null("Mission Start Overlay")
	if start_overlay != null:
		start_overlay.hide()


func save_mission_to_file(path: String):
	# Show elements in the mission scene that we hid for the editor
	var hud = mission_node.get_node_or_null("HUD")
	if hud != null:
		hud.show()

	var start_overlay = mission_node.get_node_or_null("Mission Start Overlay")
	if start_overlay != null:
		start_overlay.show()

	var mission_scene = PackedScene.new()
	var scene_error = mission_scene.pack(mission_node)

	if scene_error == OK:
		var resource_save_error = ResourceSaver.save(path, mission_scene)
		if resource_save_error == OK:
			open_file_dialog.invalidate()
			save_file_dialog.invalidate()
		else:
			print("Error saving mission scene: " + str(resource_save_error))
	else:
		print("Error packing mission scene: " + str(scene_error))

	# ...and hide them again
	if hud != null:
		hud.hide()

	if start_overlay != null:
		start_overlay.hide()


func set_ship_loadout(ship, new_loadout: Dictionary):
	var ship_loadout = {}
	var wing_index: int = get_wing_index(ship)

	if wing_index != -1:
		for loadout in default_loadouts[wing_index]:
			if loadout.name == ship.name:
				loadout = new_loadout
				return true
	elif non_player_loadouts.has(ship.name):
		non_player_loadouts[ship.name] = new_loadout
		return true

	return false


const AttackShipBase = preload("res://scripts/AttackShipBase.gd")
const NPCShip = preload("res://scripts/NPCShip.gd")
const Player = preload("res://scripts/Player.gd")

const DEFAULT_MISSION = preload("res://editor/default_mission.tscn")
