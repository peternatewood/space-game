extends "res://scripts/RadialMenu.gd"


func set_options(weapon_data: Dictionary):
	var icons_container = get_node("Radial Container/Icons Container")
	var radian_increment: float = TAU / weapon_data.keys().size()
	var radians: float = 0

	for weapon_name in weapon_data.keys():
		var icon = RADIAL_ICON.instance()
		icons_container.add_child(icon)
		icon.weapon_name = weapon_name
		icon.set_normal_texture(weapon_data[weapon_name].icon)

		var icon_position = Vector2(HALF_RADIUS * cos(radians), HALF_RADIUS * sin(radians))
		icon.set_position(icon_position - icon.rect_size / 2)

		radians += radian_increment
