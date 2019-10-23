extends Label

var enabled: bool = true
var ship
var ship_destroyed: bool = false
var ship_warped_in: bool
var wing_destroyed: bool = false
var wing_name: String
var wing_ships: Array = []
var wing_warped_in: bool = true


func _on_ship_destroyed():
	ship_destroyed = true
	emit_signal("ship_destroyed")
	queue_free()


func _on_ship_warped_in():
	show()


func _on_wing_ship_destroyed(destroyed_ship):
	var index: int = 0
	for ship in wing_ships:
		if ship == destroyed_ship:
			wing_ships.remove(index)
			break

		index += 1

	if wing_ships.size() < 1:
		wing_destroyed = true
		disable()


func _on_wing_warped_in():
	wing_warped_in = true
	show()


# PUBLIC


func disable():
	enabled = false
	set_modulate(HALF_OPACITY_WHITE)


func set_number(number: int):
	set_text(str(number) + ". " + ship.name)


func set_ship(node, number: int):
	ship = node
	ship.connect("destroyed", self, "_on_ship_destroyed")
	ship.connect("warped_out", self, "_on_ship_destroyed")
	set_number(number)

	if not ship.is_warped_in:
		hide()
		ship.connect("warped_in", self, "_on_ship_warped_in")


func set_wing(name, ships, number: int, is_reinforcement_wing: bool = false):
	for ship in ships:
		wing_ships.append(ship)
		ship.connect("destroyed", self, "_on_wing_ship_destroyed", [ ship ])
		ship.connect("warped_out", self, "_on_wing_ship_destroyed", [ ship ])

		if not is_reinforcement_wing:
			if wing_warped_in and not ship.is_warped_in:
				wing_warped_in = false
				ship.connect("warped_in", self, "_on_wing_warped_in")

	wing_name = name
	set_text(str(number) + ". " + name)

	if not wing_warped_in:
		hide()


signal ship_destroyed

const HALF_OPACITY_WHITE: Color = Color(1.0, 1.0, 1.0, 0.5)
