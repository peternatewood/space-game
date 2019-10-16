extends Label

var ship


func _on_ship_destroyed():
	queue_free()


# PUBLIC


func set_ship(node, number: int):
	ship = node
	ship.connect("destroyed", self, "_on_ship_destroyed")
	set_text(str(number) + ". " + node.name)
