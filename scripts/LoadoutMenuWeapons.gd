extends "res://scripts/LoadoutMenuBase.gd"


func set_options(weapon_resources: Dictionary):
	var icons_container = get_node("Popup/Icons Scroll Container/Icons Margin/Icons VBox")

	if weapon_resources.keys().size() == 1:
		var weapon_name = weapon_resources.keys()[0]
		var icon_size = weapon_resources[weapon_name].icon.get_size()

		var icon = LOADOUT_ICON.instance()
		icons_container.add_child(icon)
		icon.weapon_name = weapon_name
		icon.set_weapon(weapon_name, weapon_resources[weapon_name].icon)
		icon.set_position(Vector2.ZERO - icon_size / 2)
	else:
		var polygon_points: PoolVector2Array
		var radian_increment: float = TAU / weapon_resources.keys().size()
		var radians: float = 0

		for weapon_name in weapon_resources.keys():
			var icon = LOADOUT_ICON.instance()
			icons_container.add_child(icon)
			icon.weapon_name = weapon_name
			icon.set_weapon(weapon_name, weapon_resources[weapon_name].icon)

			var icon_size = weapon_resources[weapon_name].icon.get_size()
			var icon_position = Vector2(HALF_RADIUS * cos(radians), HALF_RADIUS * sin(radians))
			icon.set_position(icon_position - icon_size / 2)

			icon.connect("pressed", self, "_on_icon_pressed", [ weapon_name, weapon_resources[weapon_name].icon ])

			radians += radian_increment
