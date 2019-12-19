extends Viewport

onready var ship_container = get_node("Ship Container")

var ship


func _process(delta):
	ship.rotate_y(delta * PI)


# PUBLIC


func show_ship(model_resource):
	for child in ship_container.get_children():
		ship_container.remove_child(child)

	ship = model_resource.instance()
	ship_container.add_child(ship)

	ship.get_node("Exhaust").hide()
	ship.get_node("Exhaust Points").hide()
	ship.rotate(Vector3.UP, TAU / 4)
	#ship.set_mass(10)
	#ship.set_angular_damp(0)
	#ship.apply_torque_impulse(SPIN_SPEED * Vector3.UP)


#const SPIN_SPEED: float = TAU
