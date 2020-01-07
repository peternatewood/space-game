extends "res://scripts/RadialMenu.gd"


func set_options(weapon_resources: Dictionary):
	var icons_container = get_node("Radial Container/Icons Container")
	var radian_increment: float = TAU / weapon_resources.keys().size()
	var radians: float = 0

	for weapon_name in weapon_resources.keys():
		var icon = RADIAL_ICON.instance()
		icons_container.add_child(icon)
		icon.weapon_name = weapon_name
		icon.set_normal_texture(weapon_resources[weapon_name].icon)

		var icon_position = Vector2(HALF_RADIUS * cos(radians), HALF_RADIUS * sin(radians))
		icon.set_position(icon_position - icon.rect_size / 2)

		icon.connect("pressed", self, "_on_icon_pressed", [ weapon_name, weapon_resources[weapon_name].icon ])

		radians += radian_increment
