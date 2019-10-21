extends "res://scripts/DraggableIcon.gd"

var ship_class: String


func _ready():
	draggable_icon.set_meta("type", WeaponSlot.TYPE.SHIP)


func _process(delta):
	._process(delta)

	if being_dragged:
		var over_area = _get_closest_overlapping_area()
		if over_area != current_closest_area:
			if current_closest_area is WingShipIcon:
				current_closest_area.highlight(false)
			if over_area is WingShipIcon:
				over_area.highlight(true)

			current_closest_area = over_area


# PUBLIC


func get_texture():
	return icon_texture.get_texture()


func set_ship(name, image_resource):
	name_label.set_text(name)
	ship_class = name

	set_texture(image_resource)


const WingShipIcon = preload("WingShipIcon.gd")
