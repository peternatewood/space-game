extends "res://scripts/RadialMenu.gd"


func disable():
	current_icon.hide()
	get_node("Cross Icon").show()


func set_options(ship_resources: Dictionary):
	var icons_container = get_node("Radial Container/Icons Container")
	var radian_increment: float = TAU / ship_resources.keys().size()
	var radians: float = 0

	for ship_class in ship_resources.keys():
		var icon = RADIAL_ICON.instance()
		icons_container.add_child(icon)
		icon.ship_class = ship_class
		icon.set_normal_texture(ship_resources[ship_class].icon)

		var icon_position = Vector2(HALF_RADIUS * cos(radians), HALF_RADIUS * sin(radians))
		icon.set_position(icon_position - icon.rect_size / 2)

		icon.connect("pressed", self, "_on_icon_pressed", [ ship_class, ship_resources[ship_class].icon ])

		radians += radian_increment
