extends Spatial

onready var mission_node = get_node("Mission Scene")
onready var open_file_dialog = get_node("Open File Dialog")
onready var save_file_dialog = get_node("Save File Dialog")

var scene_file_regex = RegEx.new()


func _ready():
	scene_file_regex.compile("^[\\w\\_\\-]+\\.tscn$")

	var file_menu = get_node("Controls Container/PanelContainer/Toolbar/File Menu")
	file_menu.get_popup().connect("id_pressed", self, "_on_file_menu_id_pressed")

	save_file_dialog.connect("confirmed", self, "_on_save_file_dialog_confirmed")


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
