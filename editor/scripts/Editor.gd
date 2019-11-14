extends Spatial

onready var add_ship_dialog = get_node("Controls Container/Add Ship Dialog")
onready var add_ship_options = get_node("Controls Container/Add Ship Dialog/Add Ship Grid/Ship Class Options")
onready var camera = get_node("Editor Camera")
onready var debug = get_node("Controls Container/Debug")
onready var debug_cube = get_node("Debug")
onready var manipulator_overlay = get_node("Controls Container/Manipulator Overlay")
onready var manipulator_viewport = get_node("Manipulator Viewport")
onready var mission_data = get_node("/root/MissionData")
onready var mission_node = get_node("Mission Scene")
onready var open_file_dialog = get_node("Controls Container/Open File Dialog")
onready var save_file_dialog = get_node("Controls Container/Save File Dialog")
onready var ship_edit_dialog = get_node("Controls Container/Ship Edit Dialog")
onready var transform_controls = get_node("Manipulator Viewport/Transform Controls")

var current_mouse_button: int = -1
var energy_weapon_index_name_map: Array = []
var has_player_ship: bool = true
var manipulator_node = null
var missile_weapon_index_name_map: Array = []
var mouse_pos: Vector2
var mouse_vel: Vector2
var scene_file_regex = RegEx.new()
var selected_node = null
var selected_node_index: int = -1
var ship_index_name_map: Array = []
var targets_container


func _ready():
	get_tree().set_pause(true)

	scene_file_regex.compile("^[\\w\\_\\-]+\\.tscn$")

	targets_container = mission_node.get_node("Targets Container")

	var file_menu = get_node("Controls Container/PanelContainer/Toolbar/File Menu")
	file_menu.get_popup().connect("id_pressed", self, "_on_file_menu_id_pressed")

	save_file_dialog.connect("confirmed", self, "_on_save_file_dialog_confirmed")

	var ship_index: int = 0
	for ship_class in mission_data.ship_models.keys():
		add_ship_options.add_item(ship_class, ship_index)
		ship_index_name_map.append(ship_class)
		ship_index += 1

	for energy_weapon_name in mission_data.energy_weapon_models.keys():
		energy_weapon_index_name_map.append(energy_weapon_name)

	for missile_weapon_name in mission_data.missile_weapon_models.keys():
		missile_weapon_index_name_map.append(missile_weapon_name)

	add_ship_dialog.connect("confirmed", self, "_on_add_ship_confirmed")

	var edit_menu = get_node("Controls Container/PanelContainer/Toolbar/Edit Menu")
	edit_menu.get_popup().connect("id_pressed", self, "_on_edit_menu_id_pressed")

	# TODO: update manipulator viewport if window size changes
	manipulator_viewport.set_size(get_viewport().size)

	ship_edit_dialog.prepare_options(mission_data)
	ship_edit_dialog.connect("player_ship_toggled", self, "_on_player_ship_toggled")
	ship_edit_dialog.connect("ship_class_changed", self, "_on_ship_class_changed")
	ship_edit_dialog.connect("ship_position_changed", self, "_on_ship_position_changed")

	ship_edit_dialog.previous_button.connect("pressed", self, "_on_edit_dialog_previous_pressed")
	ship_edit_dialog.next_button.connect("pressed", self, "_on_edit_dialog_next_pressed")

	get_node("Controls Container/Viewport Dummy Control").connect("gui_input", self, "_on_controls_gui_input")


func _on_add_ship_confirmed():
	var ship_class = ship_index_name_map[add_ship_options.get_selected_id()]
	var ship_instance = mission_data.ship_models[ship_class].instance()
	ship_instance.set_script(NPCShip)
	targets_container.add_child(ship_instance)


func _on_controls_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			current_mouse_button = event.button_index
		else:
			# TODO: Check which buttons are still pressed, if any
			current_mouse_button = -1

		match event.button_index:
			BUTTON_LEFT:
				#if event.pressed and not ship_edit_dialog.has_point(event.position):
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

							ship_edit_dialog.fill_ship_info(selected_node)
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


func _on_edit_dialog_previous_pressed():
	var next_index = (selected_node_index - 1) % targets_container.get_child_count()

	if next_index != selected_node_index:
		selected_node_index = next_index
		selected_node = targets_container.get_child(selected_node_index)
		ship_edit_dialog.fill_ship_info(selected_node)


func _on_edit_dialog_next_pressed():
	var next_index = (selected_node_index + 1) % targets_container.get_child_count()

	if next_index != selected_node_index:
		selected_node_index = next_index
		selected_node = targets_container.get_child(selected_node_index)
		ship_edit_dialog.fill_ship_info(selected_node)


func _on_edit_menu_id_pressed(item_id: int):
	match item_id:
		0:
			add_ship_dialog.popup_centered()


func _on_file_menu_id_pressed(item_id: int):
	match item_id:
		0:
			# TODO: replace the current mission with the default mission
			pass
		1:
			open_file_dialog.popup_centered()
		2:
			save_file_dialog.popup_centered()


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


func _on_save_file_dialog_confirmed():
	if save_file_dialog.current_file.length() == 0:
		print("No file name provided")
	elif scene_file_regex.search(save_file_dialog.current_file) == null:
		print("Invalid file name: " + save_file_dialog.current_file)
	else:
		var mission_scene = PackedScene.new()
		var scene_error = mission_scene.pack(mission_node)
		if scene_error == OK:
			var resource_save_error = ResourceSaver.save(save_file_dialog.current_path, mission_scene)
			if resource_save_error != OK:
				print("Error saving mission scene: " + str(resource_save_error))
		else:
			print("Error packing mission scene: " + str(scene_error))


func _on_ship_class_changed(ship_index: int):
	if ship_index < ship_index_name_map.size():
		var ship_instance = mission_data.ship_models[ship_index_name_map[ship_index]].instance()
		# Copy over all properties from existing ship
		ship_instance.set_script(ship_edit_dialog.edit_ship.get_script())
		ship_instance.hull_hitpoints = ship_edit_dialog.edit_ship.hull_hitpoints
		ship_instance.name = ship_edit_dialog.edit_ship.name
		ship_instance.wing_name = ship_edit_dialog.edit_ship.wing_name

		# This method doesn't seem to work as expected: the old model sticks around
		#ship_edit_dialog.edit_ship.replace_by(ship_instance)

		mission_node.add_child(ship_instance)
		ship_instance.transform = ship_edit_dialog.edit_ship.transform

		ship_edit_dialog.edit_ship.free()
		ship_edit_dialog.edit_ship = ship_instance
		selected_node = ship_instance
	else:
		print("Invalid ship index selected: " + str(ship_index))


func _on_ship_position_changed(position: Vector3):
	transform_controls.transform.origin = position


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


const NPCShip = preload("res://scripts/NPCShip.gd")
const Player = preload("res://scripts/Player.gd")

"""
// intersect3D_SegmentPlane(): intersect a segment and a plane
//    Input:  S = a segment, and Pn = a plane = {Point V0;  Vector n;}
//    Output: *I0 = the intersect point (when it exists)
//    Return: 0 = disjoint (no intersection)
//            1 =  intersection in the unique point *I0
//            2 = the  segment lies in the plane
int
intersect3D_SegmentPlane( Segment S, Plane Pn, Point* I )
{
    Vector    u = S.P1 - S.P0;
    Vector    w = S.P0 - Pn.V0;

    float     D = dot(Pn.n, u);
    float     N = -dot(Pn.n, w);

    if (fabs(D) < SMALL_NUM) {           // segment is parallel to plane
        if (N == 0)                      // segment lies in plane
            return 2;
        else
            return 0;                    // no intersection
    }
    // they are not parallel
    // compute intersect param
    float sI = N / D;
    if (sI < 0 || sI > 1)
        return 0;                        // no intersection

    *I = S.P0 + sI * u;                  // compute segment intersect point
    return 1;
}
"""
