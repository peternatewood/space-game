extends "res://scripts/DraggableIcon.gd"

var weapon_name: String


func set_weapon(name, image_resource, type):
	draggable_icon.set_meta("type", type)
	name_label.set_text(name)
	weapon_name = name

	set_texture(image_resource)
