extends Label

var ship
var ship_destroyed: bool = false
var wing_ships: Array = []
var wing_destroyed: bool = false


func _on_ship_destroyed():
	ship_destroyed = true
	emit_signal("ship_destroyed")
	queue_free()


func _on_wing_ship_destroyed(destroyed_ship):
	var index: int = 0
	for ship in wing_ships:
		if ship == destroyed_ship:
			wing_ships.remove(index)
			break

		index += 1

	if wing_ships.size() < 1:
		wing_destroyed = true
		set_modulate(HALF_OPACITY_WHITE)


# PUBLIC


func set_number(number: int):
	set_text(str(number) + ". " + ship.name)


func set_ship(node, number: int):
	ship = node
	ship.connect("destroyed", self, "_on_ship_destroyed")
	set_number(number)


func set_wing(name, ships, number: int):
	for ship in ships:
		wing_ships.append(ship)
		ship.connect("destroyed", self, "_on_wing_ship_destroyed", [ ship ])

	set_text(str(number) + ". " + name)


signal ship_destroyed

const HALF_OPACITY_WHITE: Color = Color(1.0, 1.0, 1.0, 0.5)
