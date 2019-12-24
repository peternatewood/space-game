extends Viewport

onready var ship_container = get_node("Ship Container")

var ship


func _ready():
	set_process(false)


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

	set_process(true)
