extends Spatial

onready var add_ship_dialog = get_node("Add Ship Dialog")
onready var add_ship_options = get_node("Add Ship Dialog/Add Ship Grid/Ship Class Options")
onready var camera = get_node("Editor Camera")
onready var debug = get_node("Controls Container/Debug")
onready var debug_cube = get_node("Debug")
onready var manipulator_overlay = get_node("Controls Container/Manipulator Overlay")
onready var manipulator_viewport = get_node("Manipulator Viewport")
onready var mission_data = get_node("/root/MissionData")
onready var mission_node = get_node("Mission Scene")
onready var open_file_dialog = get_node("Open File Dialog")
onready var save_file_dialog = get_node("Save File Dialog")
onready var ship_edit_dialog = get_node("Ship Edit Dialog")
onready var transform_controls = get_node("Manipulator Viewport/Transform Controls")

var current_mouse_button: int = -1
var manipulator_node = null
var mouse_pos: Vector2
var mouse_vel: Vector2
var scene_file_regex = RegEx.new()
var selected_node = null
var ship_index_name_map: Array = []


func _ready():
	scene_file_regex.compile("^[\\w\\_\\-]+\\.tscn$")

	var file_menu = get_node("Controls Container/PanelContainer/Toolbar/File Menu")
	file_menu.get_popup().connect("id_pressed", self, "_on_file_menu_id_pressed")

	save_file_dialog.connect("confirmed", self, "_on_save_file_dialog_confirmed")

	var ship_index: int = 0
	for ship_class in mission_data.ship_models.keys():
		add_ship_options.add_item(ship_class, ship_index)
		ship_index_name_map.append(ship_class)
		ship_index += 1

	var edit_menu = get_node("Controls Container/PanelContainer/Toolbar/Edit Menu")
	edit_menu.get_popup().connect("id_pressed", self, "_on_edit_menu_id_pressed")

	# TODO: update manipulator viewport if window size changes
	manipulator_viewport.set_size(get_viewport().size)

	ship_edit_dialog.prepare_options(mission_data)

	get_node("Controls Container/Viewport Dummy Control").connect("gui_input", self, "_on_controls_gui_input")


func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			current_mouse_button = event.button_index
		else:
			# TODO: Check which buttons are still pressed, if any
			current_mouse_button = -1
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


func _on_controls_gui_input(event):
	if event is InputEventMouseButton:
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
			BUTTON_WHEEL_DOWN:
				camera.zoom_out()


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
