extends "res://scripts/LoadoutMenuBase.gd"


func disable():
	current_icon.hide()
	get_node("Cross Icon").show()


func set_options(ship_resources: Dictionary):
	var icons_container = get_node("Popup/Icons Scroll Container/Icons Margin/Icons VBox")

	if ship_resources.keys().size() == 1:
		var ship_class = ship_resources.keys()[0]
		var icon_size = ship_resources[ship_class].icon.get_size()

		var icon = LOADOUT_ICON.instance()
		icons_container.add_child(icon)
		icon.ship_class = ship_class
		icon.set_ship(ship_class, ship_resources[ship_class].icon)
		icon.set_position(Vector2.ZERO - icon_size / 2)
	else:
		var radian_increment: float = TAU / ship_resources.keys().size()
		var radians: float = 0

		for ship_class in ship_resources.keys():
			var icon = LOADOUT_ICON.instance()
			icons_container.add_child(icon)
			icon.ship_class = ship_class
			icon.set_ship(ship_class, ship_resources[ship_class].icon)

			var icon_size = ship_resources[ship_class].icon.get_size()
			var icon_position = Vector2(HALF_RADIUS * cos(radians), HALF_RADIUS * sin(radians))
			icon.set_position(icon_position - icon_size / 2)

			icon.connect("pressed", self, "_on_icon_pressed", [ ship_class, ship_resources[ship_class].icon ])

			radians += radian_increment
