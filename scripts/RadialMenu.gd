extends Control


func set_icons(images: Array):
	var icons_container = get_node("Icons Container")
	var radian_increment: float = TAU / images.size()
	var radians: float = 0

	for image in images:
		var icon = RADIAL_ICON.instance()
		icons_container.add_child(icon)
		icon.set_normal_texture(image)

		var icon_position = Vector2(HALF_RADIUS * cos(radians), HALF_RADIUS * sin(radians))
		icon.set_position(icon_position - icon.rect_size / 2)

		radians += radian_increment


const HALF_RADIUS: float = 106.0
const RADIAL_ICON = preload("res://prefabs/radial_icon.tscn")
