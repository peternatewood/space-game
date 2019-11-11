extends Spatial

onready var camera = get_node("Editor Camera")
onready var manipulator_overlay = get_node("Controls Container/Manipulator Overlay")
onready var manipulator_viewport = get_node("Manipulator Viewport")
onready var mission_node = get_node("Mission Scene")
onready var open_file_dialog = get_node("Open File Dialog")
onready var save_file_dialog = get_node("Save File Dialog")
onready var transform_controls = get_node("Manipulator Viewport/Transform Controls")

var current_mouse_button: int = -1
var mouse_pos: Vector2
var scene_file_regex = RegEx.new()
var selected_node = null


func _ready():
	scene_file_regex.compile("^[\\w\\_\\-]+\\.tscn$")

	var file_menu = get_node("Controls Container/PanelContainer/Toolbar/File Menu")
	file_menu.get_popup().connect("id_pressed", self, "_on_file_menu_id_pressed")

	save_file_dialog.connect("confirmed", self, "_on_save_file_dialog_confirmed")


func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			current_mouse_button = event.button_index

			match event.button_index:
				BUTTON_LEFT:
					selected_node = camera.get_node_at_position(event.position)

					if selected_node == null:
						manipulator_overlay.hide()
						transform_controls.toggle(false)
					else:
						manipulator_viewport.update_camera(camera)
						manipulator_overlay.show()
						transform_controls.toggle(true)
		else:
			# TODO: Check which buttons are still pressed, if any
			current_mouse_button = -1
	elif event is InputEventMouseMotion:
		mouse_pos = event.position

		if current_mouse_button == BUTTON_MIDDLE:
			if event.shift:
				camera.move_position(event.relative)
			else:
				camera.orbit(event.relative)

			if manipulator_overlay.visible:
				manipulator_viewport.update_camera(camera)


func _on_file_menu_id_pressed(item_id: int):
	match item_id:
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
