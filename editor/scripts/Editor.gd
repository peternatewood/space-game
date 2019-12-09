extends Spatial

onready var about_window = get_node("Controls Container/About Window")
onready var add_ship_dialog = get_node("Controls Container/Add Ship Dialog")
onready var add_waypoint_dialog = get_node("Controls Container/Add Waypoint Dialog")
onready var armory_dialog = get_node("Controls Container/Armory Dialog")
onready var camera = get_node("Editor Camera")
onready var debug = get_node("Controls Container/Debug")
onready var debug_cube = get_node("Debug")
onready var details_dialog = get_node("Controls Container/Details Dialog")
onready var edit_waypoints_panel = get_node("Controls Container/Waypoint Edit Panel")
onready var icons_container = get_node("Controls Container/Icons Container")
onready var loader = get_node("/root/SceneLoader")
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
onready var waypoint_groups_dialog = get_node("Controls Container/Waypoint Groups Dialog")
onready var wings_dialog = get_node("Controls Container/Wings Dialog")

var armory: Dictionary
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
var waypoint_groups: Array = []
var waypoints_container
var wing_names: Array = []


func _ready():
	get_tree().set_pause(true)

	scene_file_regex.compile("^[\\w\\_\\-]+\\.tscn$")

	armory_dialog.populate_items(mission_data.ship_models.keys(), mission_data.energy_weapon_models.keys(), mission_data.missile_weapon_models.keys())

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
	for ship_class in mission_data.ship_models.keys():
		ship_index_name_map.append(ship_class)

	add_ship_dialog.populate_ship_options(ship_index_name_map)
	add_ship_dialog.connect("confirmed", self, "_on_add_ship_confirmed")

	for beam_weapon_name in mission_data.beam_weapon_models.keys():
		ship_edit_dialog.beam_weapon_index_name_map.append(beam_weapon_name)

	for energy_weapon_name in mission_data.energy_weapon_models.keys():
		ship_edit_dialog.energy_weapon_index_name_map.append(energy_weapon_name)

	for missile_weapon_name in mission_data.missile_weapon_models.keys():
		ship_edit_dialog.missile_weapon_index_name_map.append(missile_weapon_name)

	# TODO: update manipulator viewport if window size changes
	#manipulator_viewport.set_size(get_viewport().size)

	ship_edit_dialog.prepare_options(mission_data, mission_node)
	ship_edit_dialog.populate_wing_options(wing_names)

	ship_edit_dialog.connect("update_pressed", self, "_on_edit_dialog_update_pressed")
	ship_edit_dialog.connect("edit_ship_deleted", self, "_on_edit_dialog_ship_deleted")
	ship_edit_dialog.previous_button.connect("pressed", self, "_on_edit_dialog_previous_pressed")
	ship_edit_dialog.next_button.connect("pressed", self, "_on_edit_dialog_next_pressed")

	icons_container.connect("gui_input", self, "_on_controls_gui_input")
	icons_container.connect("icon_clicked", self, "_on_icon_clicked")
	icons_container.connect("waypoint_icon_clicked", self, "_on_waypoint_icon_clicked")

	wings_dialog.populate_wing_names(wing_names)
	wings_dialog.connect("confirmed", self, "_on_wings_dialog_confirmed")

	objectives_window.connect("objective_added", self, "_on_objectives_window_objective_added")
	objectives_window.connect("delete_button_pressed", self, "_on_objectives_delete_button_pressed")
	objectives_window.connect("edit_button_pressed", self, "_on_objectives_edit_button_pressed")
	objectives_edit_dialog.connect("confirmed", self, "_on_objectives_dialog_confirmed")

	details_dialog.connect("confirmed", self, "_on_details_dialog_confirmed")

	waypoint_groups_dialog.connect("confirmed", self, "_on_waypoint_groups_confirmed")
	add_waypoint_dialog.connect("confirmed", self, "_on_add_waypoint_confirmed")
	edit_waypoints_panel.connect("add_pressed", self, "_on_edit_waypoints_add_pressed")
	edit_waypoints_panel.connect("waypoint_deleted", self, "_on_waypoint_deleted")

	armory_dialog.connect("confirmed", self, "_on_armory_confirmed")


func _on_add_ship_confirmed():
	# Run validations first
	var ship_name = add_ship_dialog.name_lineedit.text
	if ship_name == "":
		add_ship_dialog.set_warning_text("Please provide a ship name")
		add_ship_dialog.popup_centered()
		return
	elif targets_container.has_node(ship_name):
		add_ship_dialog.set_warning_text("Ship " + ship_name + " already exists. Please provide a unique ship name")
		add_ship_dialog.popup_centered()
		return
	else:
		add_ship_dialog.set_warning_text("", false)

	var ship_class: String
	var ship_instance

	ship_class = ship_index_name_map[add_ship_dialog.ship_options.get_selected_id()]
	ship_instance = mission_data.ship_models[ship_class].instance()
	ship_instance.set_script(NPCShip)

	ship_instance.set_name(ship_name)
	targets_container.add_child(ship_instance)
	ship_instance.set_owner(mission_node)

	var beam_weapon_count: int = 0
	var energy_weapon_count: int = 0
	var missile_weapon_count: int = 0

	if ship_instance.is_capital_ship:
		beam_weapon_count = ship_instance.beam_weapon_turrets.size()
		energy_weapon_count = ship_instance.energy_weapon_turrets.size()
		missile_weapon_count = ship_instance.missile_weapon_turrets.size()
	else:
		energy_weapon_count = ship_instance.energy_weapon_hardpoints.size()
		missile_weapon_count = ship_instance.missile_weapon_hardpoints.size()

	non_player_loadouts[ship_instance.name] = {
		"beam_weapons": [],
		"energy_weapons": [],
		"missile_weapons": []
	}

	for index in range(beam_weapon_count):
		non_player_loadouts[ship_instance.name].beam_weapons.append("")

	for index in range(energy_weapon_count):
		non_player_loadouts[ship_instance.name].energy_weapons.append("")

	for index in range(missile_weapon_count):
		non_player_loadouts[ship_instance.name].missile_weapons.append("")

	mission_node.set_meta("non_player_loadouts", non_player_loadouts)

	# Update edit dialog
	if ship_edit_dialog.visible:
		selected_node = ship_instance
		selected_node_index = ship_instance.get_position_in_parent()

		var ship_loadout = get_ship_loadout(selected_node)
		ship_edit_dialog.fill_ship_info(selected_node, ship_loadout)

	# Add an icon
	icons_container.add_icon(ship_instance)


func _on_add_waypoint_confirmed():
	var group_index: int = add_waypoint_dialog.get_group_index()
	var group_name = waypoint_groups[group_index]

	add_waypoint(group_name)


func _on_armory_confirmed():
	armory = armory_dialog.get_armory()
	mission_node.set_meta("armory", armory)


func _on_controls_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			current_mouse_button = event.button_index
		else:
			# TODO: Check which buttons are still pressed, if any
			current_mouse_button = -1
# TODO: figure out how to get intersects correctly: this doesn't work after moving objects in the scene
		match event.button_index:
			BUTTON_LEFT:
				if event.pressed:
					# Check manipulator viewport raycast first
					var manipulator_intersect
					#if manipulator_overlay.visible:
					#	manipulator_viewport.update_camera(camera)
					#	manipulator_intersect = manipulator_viewport.get_node_at_position(event.position)

					if manipulator_intersect != null:
						manipulator_node = manipulator_intersect.collider
					else:
						selected_node = camera.get_node_at_position(event.position)
						selected_node_index = selected_node.get_position_in_parent() if selected_node != null else -1
						manipulator_node = null

						if selected_node != null:
							#manipulator_viewport.update_camera(camera)
							#transform_controls.toggle(true)
							#transform_controls.scale = selected_node.get_meta("cam_distance") * Vector3.ONE
							#transform_controls.transform.origin = selected_node.transform.origin
							#manipulator_overlay.show()

							var ship_loadout = get_ship_loadout(selected_node)

							ship_edit_dialog.fill_ship_info(selected_node, ship_loadout)
							ship_edit_dialog.show()
						#else:
						#	manipulator_overlay.hide()
						#	transform_controls.toggle(false)

							ship_edit_dialog.hide()
			BUTTON_WHEEL_UP:
				camera.zoom_in()
				#if manipulator_overlay.visible:
				#	manipulator_viewport.update_camera(camera)
			BUTTON_WHEEL_DOWN:
				camera.zoom_out()
				#if manipulator_overlay.visible:
				#	manipulator_viewport.update_camera(camera)
	elif event is InputEventMouseMotion:
		mouse_pos = event.position
		mouse_vel = event.relative

		match current_mouse_button:
			BUTTON_MIDDLE:
				if event.shift:
					camera.move_position(event.relative)
				else:
					camera.orbit(event.relative)

				#if manipulator_overlay.visible:
				#	manipulator_viewport.update_camera(camera)


func _on_details_dialog_confirmed():
	mission_node.set_meta("name", details_dialog.name_lineedit.text)
	mission_node.set_meta("briefing", [ details_dialog.briefing_textedit.text ])


func _on_edit_dialog_next_pressed():
	var next_index = (selected_node_index + 1) % targets_container.get_child_count()

	if next_index != selected_node_index:
		selected_node_index = next_index
		selected_node = targets_container.get_child(selected_node_index)
		ship_edit_dialog.fill_ship_info(selected_node, get_ship_loadout(selected_node))


func _on_edit_dialog_previous_pressed():
	var next_index = selected_node_index - 1
	if next_index < 0:
		next_index += targets_container.get_child_count()

	if next_index != selected_node_index:
		selected_node_index = next_index
		selected_node = targets_container.get_child(selected_node_index)
		ship_edit_dialog.fill_ship_info(selected_node, get_ship_loadout(selected_node))


func _on_edit_dialog_ship_deleted():
	var ship_count = targets_container.get_child_count()

	# Since we queue_free the ship, the count probably still includes the deleted ship
	if ship_count <= 1:
		ship_edit_dialog.hide()
	else:
		_on_edit_dialog_next_pressed()


func _on_edit_waypoints_add_pressed():
	var group_name = edit_waypoints_panel.get_selected_group_name()
	add_waypoint(group_name)


func _on_edit_menu_id_pressed(item_id: int):
	match item_id:
		0:
			add_ship_dialog.popup_centered()
		1:
			var targets_count = targets_container.get_child_count()
			if targets_count == 0:
				print("No ships to edit!")
			else:
				selected_node_index = clamp(selected_node_index, targets_count - 1, 0)
				selected_node = targets_container.get_child(selected_node_index)

				# Hide other panels
				edit_waypoints_panel.hide()

				ship_edit_dialog.fill_ship_info(selected_node, get_ship_loadout(selected_node))
				ship_edit_dialog.show()
		2:
			if waypoint_groups.size() == 0:
				print("No waypoint groups!")
			else:
				add_waypoint_dialog.popup_centered()
		3:
			if waypoint_groups.size() == 0:
				print("No waypoint groups!")
			else:
				edit_waypoints_panel.show()

				# Hide other panels
				ship_edit_dialog.hide()


func _on_edit_dialog_update_pressed():
	# Get current ship properties
	var old_name: String = ship_edit_dialog.edit_ship.name
	var wing_index: int = get_wing_index(ship_edit_dialog.edit_ship)
	var old_player_status: bool = ship_edit_dialog.edit_ship is Player
	var old_ship_class: String = ship_edit_dialog.edit_ship.ship_class

	var new_name: String = ship_edit_dialog.name_lineedit.text
	var new_wing_index: int = ship_edit_dialog.get_wing_index()
	var new_player_status: bool = ship_edit_dialog.player_ship_checkbox.pressed

	# Update ship properties
	ship_edit_dialog.edit_ship.set_name(new_name)
	ship_edit_dialog.edit_ship.hull_hitpoints = ship_edit_dialog.hitpoints_spinbox.value
	ship_edit_dialog.edit_ship.faction = ship_edit_dialog.get_faction_name()

	var new_ship_class: String = ship_index_name_map[ship_edit_dialog.ship_class_options.get_selected_id()]
	if not ship_edit_dialog.edit_ship.is_capital_ship:
		ship_edit_dialog.edit_ship.wing_name = wing_names[new_wing_index]

	if ship_edit_dialog.edit_ship is NPCShip:
		ship_edit_dialog.edit_ship.is_warped_in = ship_edit_dialog.warped_in_checkbox.pressed

	# Get ship loadout
	var ship_loadout
	if wing_index == -1:
		# Change the key for this loadout if the name changed
		ship_loadout = non_player_loadouts.get(old_name)
		if ship_loadout == null:
			print("No such loadout for name: " + old_name)
			print(non_player_loadouts)
			return
	else:
		# Change the loadout's name if it changed
		for loadout in default_loadouts[wing_index]:
			if loadout.name == old_name:
				ship_loadout = loadout

				if old_name != new_name:
					loadout.name = new_name
				break

	# Toggle player ship status
	if old_player_status != new_player_status:
		if new_player_status:
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

			# Assign Player script to ship
			var ship_data: Dictionary = {
				"hull_hitpoints": ship_edit_dialog.edit_ship.hull_hitpoints,
				"faction": ship_edit_dialog.edit_ship.faction,
				"ship_class": ship_edit_dialog.edit_ship.ship_class,
				"wing_name": ship_edit_dialog.edit_ship.wing_name
			}
			ship_edit_dialog.edit_ship.set_script(Player)

			# Re-apply script properties that will have been lost
			ship_edit_dialog.edit_ship.hull_hitpoints = ship_data.hull_hitpoints
			ship_edit_dialog.edit_ship.faction = ship_data.faction
			ship_edit_dialog.edit_ship.ship_class = ship_data.ship_class
			ship_edit_dialog.edit_ship.wing_name = ship_data.wing_name

			# Run _ready again so we get all the onready vars loaded
			ship_edit_dialog.edit_ship._ready()
		else:
			var ship_data: Dictionary = {
				"hull_hitpoints": ship_edit_dialog.edit_ship.hull_hitpoints,
				"faction": ship_edit_dialog.edit_ship.faction,
				"is_warped_in": ship_edit_dialog.edit_ship.is_warped_in,
				"ship_class": ship_edit_dialog.edit_ship.ship_class,
				"wing_name": ship_edit_dialog.edit_ship.wing_name
			}
			ship_edit_dialog.edit_ship.set_script(NPCShip)

			# Re-apply script properties that will have been lost
			ship_edit_dialog.edit_ship.hull_hitpoints = ship_data.hull_hitpoints
			ship_edit_dialog.edit_ship.faction = ship_data.faction
			ship_edit_dialog.edit_ship.is_warped_in = ship_data.is_warped_in
			ship_edit_dialog.edit_ship.ship_class = ship_data.ship_class
			ship_edit_dialog.edit_ship.wing_name = ship_data.wing_name

			# Run _ready again so we get all the onready vars loaded
			ship_edit_dialog.edit_ship._ready()

	# TODO: display notification in a corner if no Player in the scene
	has_player_ship = new_player_status

	# Update ship class
	if old_ship_class != new_ship_class:
		var ship_instance = mission_data.ship_models[new_ship_class].instance()
		# Copy over all properties from existing ship
		ship_instance.set_script(ship_edit_dialog.edit_ship.get_script())
		ship_instance.hull_hitpoints = ship_edit_dialog.edit_ship.hull_hitpoints

		var ship_transform = ship_edit_dialog.edit_ship.transform

		# This method doesn't seem to work as expected: the old model sticks around
		#ship_edit_dialog.edit_ship.replace_by(ship_instance)

		targets_container.add_child(ship_instance)
		ship_instance.set_owner(mission_node)
		ship_instance.transform = ship_transform

		var beam_weapon_count: int = 0
		var energy_weapon_count: int = 0
		var missile_weapon_count: int = 0

		if ship_instance.is_capital_ship:
			beam_weapon_count = ship_instance.beam_weapon_turrets.size()
			energy_weapon_count = ship_instance.energy_weapon_turrets.size()
			missile_weapon_count = ship_instance.missile_weapon_turrets.size()
		else:
			ship_instance.wing_name = ship_edit_dialog.edit_ship.wing_name

			energy_weapon_count = ship_instance.energy_weapon_hardpoints.size()
			missile_weapon_count = ship_instance.missile_weapon_hardpoints.size()

		# Update loadout for new ship class
		if beam_weapon_count < ship_loadout.beam_weapons.size():
			for index in range(beam_weapon_count, ship_loadout.beam_weapons.size()):
				ship_loadout.beam_weapons.remove(beam_weapon_count)
		elif beam_weapon_count > ship_loadout.beam_weapons.size():
			for index in range(ship_loadout.beam_weapons.size(), beam_weapon_count):
				ship_loadout.beam_weapons.append("")

		if energy_weapon_count < ship_loadout.energy_weapons.size():
			for index in range(energy_weapon_count, ship_loadout.energy_weapons.size()):
				ship_loadout.energy_weapons.remove(energy_weapon_count)
		elif energy_weapon_count > ship_loadout.energy_weapons.size():
			for index in range(ship_loadout.energy_weapons.size(), energy_weapon_count):
				ship_loadout.energy_weapons.append("")

		if missile_weapon_count < ship_loadout.missile_weapons.size():
			for index in range(missile_weapon_count, ship_loadout.missile_weapons.size()):
				ship_loadout.missile_weapons.remove(missile_weapon_count)
		elif missile_weapon_count > ship_loadout.missile_weapons.size():
			for index in range(ship_loadout.missile_weapons.size(), missile_weapon_count):
				ship_loadout.missile_weapons.append("")

		var ship_name: String = ship_edit_dialog.edit_ship.name

		ship_edit_dialog.edit_ship.free()

		ship_instance.set_name(ship_name)
		ship_edit_dialog.edit_ship = ship_instance
		selected_node = ship_instance

		# The old icon will be gone, so add this new one
		icons_container.add_icon(ship_instance)

	# Move loadout from non_player to default, or vice versa
	if wing_index != new_wing_index:
		if new_wing_index == -1:
			# Change loadout from default to non_player
			var ship_index: int = 0

			# Remove old loadout
			for loadout in default_loadouts[wing_index]:
				# Apparently, the name value is already updated? I guess it must be a reference rather than its own string
				#if loadout.name == old_name:
				if loadout.name == new_name:
					default_loadouts[wing_index].remove(ship_index)
					break
				ship_index += 1

			ship_loadout.erase("name")
			non_player_loadouts[new_name] = ship_loadout
		else:
			if wing_index == -1:
				# Change loadout from non_player to default
				ship_loadout["name"] = new_name
				default_loadouts[new_wing_index].append(ship_loadout)
				non_player_loadouts.erase(old_name)
			else:
				# Move loadout to new wing
				default_loadouts[new_wing_index].append(ship_loadout)

				# Remove old loadout
				var ship_index: int = 0
				for loadout in default_loadouts[wing_index]:
					if loadout.name == old_name:
						default_loadouts[wing_index].remove(ship_index)
						break
					ship_index += 1

	# Update ship loadout
	var beam_weapons = ship_edit_dialog.get_beam_weapon_selections()
	for slot_index in range(beam_weapons.size()):
		if ship_loadout.beam_weapons.size() <= slot_index:
			ship_loadout.beam_weapons.append(beam_weapons[slot_index])
		else:
			ship_loadout.beam_weapons[slot_index] = beam_weapons[slot_index]

	var energy_weapons = ship_edit_dialog.get_energy_weapon_selections()
	for slot_index in range(energy_weapons.size()):
		if ship_loadout.energy_weapons.size() <= slot_index:
			ship_loadout.energy_weapons.append(energy_weapons[slot_index])
		else:
			ship_loadout.energy_weapons[slot_index] = energy_weapons[slot_index]

	var missile_weapons = ship_edit_dialog.get_missile_weapon_selections()
	for slot_index in range(missile_weapons.size()):
		if ship_loadout.missile_weapons.size() <= slot_index:
			ship_loadout.missile_weapons.append(missile_weapons[slot_index])
		else:
			ship_loadout.missile_weapons[slot_index] = missile_weapons[slot_index]

	if new_wing_index != -1:
		for loadout in default_loadouts[new_wing_index]:
			if loadout.name == old_name:
				if old_name != new_name:
					loadout.name = new_name

				loadout = ship_loadout
	elif old_name != new_name:
		non_player_loadouts[new_name] = ship_loadout

		if non_player_loadouts.has(old_name):
			non_player_loadouts.erase(old_name)

	if ship_edit_dialog.edit_ship is Player:
		mission_node.set_meta("player_path", "Targets Container/" + ship_edit_dialog.edit_ship.name)
	elif ship_edit_dialog.edit_ship is NPCShip:
		ship_edit_dialog.edit_ship.initial_orders = ship_edit_dialog.get_orders()

	# Update node meta data, under the assumption it has changed
	mission_node.set_meta("non_player_loadouts", non_player_loadouts)
	mission_node.set_meta("default_loadouts", default_loadouts)


func _on_icon_clicked(node):
	if node == null:
		print("No such node attached!")
		return

	selected_node = node
	selected_node_index = selected_node.get_position_in_parent()
	manipulator_node = null

	var ship_loadout = get_ship_loadout(selected_node)

	ship_edit_dialog.fill_ship_info(selected_node, ship_loadout)
	ship_edit_dialog.show()


func _on_file_menu_id_pressed(item_id: int):
	match item_id:
		0:
			mission_node.free()

			mission_node = DEFAULT_MISSION.instance()
			add_child(mission_node)

			load_mission_info()
		1:
			open_file_dialog.popup_centered()
		2:
			save_file_dialog.popup_centered()
		3:
			loader.load_scene("res://title.tscn")
		4:
			get_tree().quit()


func _on_help_menu_id_pressed(item_id: int):
	match item_id:
		0:
			about_window.popup_centered()
		1:
			manual_window.popup_centered()


func _on_mission_menu_id_pressed(item_id: int):
	match item_id:
		0:
			details_dialog.populate_fields(mission_node.get_meta("name"), mission_node.get_meta("briefing"))
			details_dialog.popup_centered()
		1:
			wings_dialog.popup_centered()
		2:
			waypoint_groups_dialog.popup_centered()
		3:
			objectives_window.show()
		4:
			armory_dialog.popup_centered()


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
	objectives_edit_dialog.populate_fields(objective, targets_container.get_children(), objectives)
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

		mission_node.free()

		mission_node = scene.instance()
		add_child(mission_node)

		load_mission_info()


func _on_save_dialog_file_selected(path: String):
	if save_file_dialog.current_file.length() == 0:
		print("No file name provided")
	elif scene_file_regex.search(save_file_dialog.current_file) == null:
		print("Invalid file name: " + save_file_dialog.current_file)
	else:
		save_mission_to_file(path)


func _on_ship_position_changed(position: Vector3):
	transform_controls.transform.origin = position


func _on_waypoint_deleted():
	# Rename waypoints in the current group
	var group_name = edit_waypoints_panel.get_selected_group_name()
	var waypoints_in_group: Array = get_tree().get_nodes_in_group(group_name)
	var number: int = 1

	for waypoint in waypoints_in_group:
		waypoint.set_name(group_name + " " + str(number))
		number += 1


func _on_waypoint_groups_confirmed():
	var new_waypoint_groups: Array = waypoint_groups_dialog.get_group_names()
	add_waypoint_dialog.populate_group_options(new_waypoint_groups)

	edit_waypoints_panel.populate_waypoint_group_options(new_waypoint_groups)
	objectives_edit_dialog.update_waypoint_groups(new_waypoint_groups)

	var current_group_count: int = waypoint_groups.size()
	var new_group_count: int = new_waypoint_groups.size()

	for index in range(max(new_group_count, current_group_count)):
		if index >= new_group_count:
			# Remove all waypoints in this removed group
			var waypoints_in_group: Array = get_tree().get_nodes_in_group(waypoint_groups[index])
			for waypoint in waypoints_in_group:
				waypoint.queue_free()
		elif index < current_group_count:
			if new_waypoint_groups[index] != waypoint_groups[index]:
				# Update each waypoint's name and group name
				var waypoints_in_group: Array = get_tree().get_nodes_in_group(waypoint_groups[index])
				var number: int = 1

				for waypoint in waypoints_in_group:
					waypoint.set_name(new_waypoint_groups[index] + " " + str(number))
					waypoint.remove_from_group(waypoint_groups[index])
					waypoint.add_to_group(new_waypoint_groups[index])
					number += 1

	waypoint_groups = new_waypoint_groups


func _on_waypoint_icon_clicked(waypoint_node):
	var waypoints = waypoints_container.get_children()
	var group_name = waypoint_node.get_groups()[0]

	edit_waypoints_panel.select_group_name(group_name)
	edit_waypoints_panel.show()


func _on_wings_dialog_confirmed():
	wing_names = wings_dialog.get_wing_names()
	ship_edit_dialog.populate_wing_options(wing_names)

	mission_node.set_meta("reinforcement_wings", wings_dialog.get_reinforcement_wings())
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


func add_waypoint(group_name: String):
	var waypoint = Position3D.new()
	waypoints_container.add_child(waypoint)
	waypoint.set_owner(mission_node)
	waypoint.add_to_group(group_name, true)

	var scene_tree = get_tree()
	var group_waypoint_count: int = scene_tree.get_nodes_in_group(group_name).size()
	waypoint.set_name(group_name + " " + str(group_waypoint_count))

	icons_container.add_waypoint_icon(waypoint)

	edit_waypoints_panel.add_waypoint(waypoint)


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
	if ship.wing_name != "":
		return wing_names.find(ship.wing_name)

	return -1


func load_mission_info():
	targets_container = mission_node.get_node("Targets Container")
	waypoints_container = mission_node.get_node("Waypoints Container")

	for waypoint in waypoints_container.get_children():
		for group in waypoint.get_groups():
			if not waypoint_groups.has(group):
				waypoint_groups.append(group)

		icons_container.add_waypoint_icon(waypoint)
		edit_waypoints_panel.add_waypoint(waypoint)

	waypoint_groups_dialog.populate_row_options(waypoint_groups)
	edit_waypoints_panel.populate_waypoint_group_options(waypoint_groups)
	# Select a group so the panel toggles the waypoint edits
	edit_waypoints_panel.waypoint_group_options.select(0)

	for meta_name in REQUIRED_META_DATA:
		if not mission_node.has_meta(meta_name):
			print("Missing required data: " + meta_name)
			return

	armory = mission_node.get_meta("armory")
	default_loadouts = mission_node.get_meta("default_loadouts")
	non_player_loadouts = mission_node.get_meta("non_player_loadouts")
	objectives = mission_node.get_meta("objectives")
	wing_names = mission_node.get_meta("wing_names")

	armory_dialog.set_items(armory["ships"], armory["energy_weapons"], armory["missile_weapons"])
	objectives_window.prepare_objectives(objectives)
	objectives_edit_dialog.update_waypoint_groups(waypoint_groups)
	objectives_edit_dialog.update_ship_names(targets_container.get_children())
	ship_edit_dialog.populate_wing_options(wing_names)
	wings_dialog.populate_wing_names(wing_names)

	# Reset all other stuff
	ship_edit_dialog.edit_ship = null
	ship_edit_dialog.hide()
	objectives_edit_dialog.hide()
	objectives_window.hide()
	camera.reset()

	# Add icons
	for child in targets_container.get_children():
		icons_container.add_icon(child)

	# Hide elements in the mission scene that shouldn't display in the editor
	var hud = mission_node.get_node_or_null("HUD")
	if hud != null:
		hud.hide()

	var start_overlay = mission_node.get_node_or_null("Mission Start Overlay")
	if start_overlay != null:
		start_overlay.hide()

	var player_movement_particles = mission_node.get_node_or_null("Player Movement Debris")
	if player_movement_particles == null:
		print("Player Movement Debris is missing!")
	else:
		player_movement_particles.hide()


func save_mission_to_file(path: String):
	# Show elements in the mission scene that we hid for the editor
	var hud = mission_node.get_node_or_null("HUD")
	if hud != null:
		hud.show()

	var start_overlay = mission_node.get_node_or_null("Mission Start Overlay")
	if start_overlay != null:
		start_overlay.show()

	var player_movement_particles = mission_node.get_node_or_null("Player Movement Debris")
	if player_movement_particles == null:
		print("Player Movement Debris is missing!")
	else:
		player_movement_particles.show()

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

	if player_movement_particles != null:
		player_movement_particles.hide()


const NPCShip = preload("res://scripts/NPCShip.gd")
const Player = preload("res://scripts/Player.gd")

const DEFAULT_MISSION = preload("res://editor/default_mission.tscn")
const REQUIRED_META_DATA: Array = [
	"default_loadouts",
	"non_player_loadouts",
	"objectives",
	"wing_names"
]
