extends "res://scripts/DraggableIcon.gd"

var weapon_name: String


func _get_closest_overlapping_area():
	var over_area = ._get_closest_overlapping_area()
	if over_area != null:
		return over_area.get_parent()

	return over_area


func _process(delta):
	._process(delta)

	if being_dragged:
		var over_area = _get_closest_overlapping_area()
		if over_area != current_closest_area:
			if current_closest_area is WeaponSlot and current_closest_area.is_area_same_type(draggable_icon):
				current_closest_area.highlight(false)
			if over_area is WeaponSlot and over_area.is_area_same_type(draggable_icon):
				over_area.highlight(true)

			current_closest_area = over_area


# PUBLIC


func set_weapon(name, image_resource, type):
	draggable_icon.set_meta("type", type)
	name_label.set_text(name)
	weapon_name = name

	set_texture(image_resource)
