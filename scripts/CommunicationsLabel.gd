extends Label

var ship
var ship_destroyed: bool = false


func _on_ship_destroyed():
	ship_destroyed = true
	emit_signal("ship_destroyed")
	queue_free()


# PUBLIC


func set_number(number: int):
	set_text(str(number) + ". " + ship.name)


func set_ship(node, number: int):
	ship = node
	ship.connect("destroyed", self, "_on_ship_destroyed")
	set_number(number)


signal ship_destroyed
