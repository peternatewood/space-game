extends Spatial

onready var open_file_dialog = get_node("Open File Dialog")
onready var save_file_dialog = get_node("Save File Dialog")


func _ready():
	var file_menu = get_node("Controls Container/PanelContainer/Toolbar/File Menu")
	file_menu.get_popup().connect("id_pressed", self, "_on_file_menu_id_pressed")


func _on_file_menu_id_pressed(item_id: int):
	match item_id:
		1:
			open_file_dialog.popup_centered()
		2:
			save_file_dialog.popup_centered()
