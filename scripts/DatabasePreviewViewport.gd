extends Viewport

onready var camera = get_node("Camera")
onready var ship = get_node("Preview Ship")


func _ready():
	toggle_ship_exhaust(false)
	set_cam_position()


func _process(delta):
	ship.rotate_y(delta * RADIANS_PER_SECOND)


# PUBLIC


func set_cam_position():
	camera.transform.origin = 1.25 * ship.cam_distance * Vector3.BACK + (ship.cam_distance / 4) * Vector3.UP
	camera.look_at(ship.transform.origin, Vector3.UP)


func set_ship(ship_instance):
	ship.free()

	add_child(ship_instance)
	ship = ship_instance
	toggle_ship_exhaust(false)

	set_cam_position()


func toggle_ship_exhaust(toggle_on: bool):
	var exhaust_points = ship.get_node_or_null("Exhaust Points")

	if toggle_on:
		ship.exhaust.show()
		if exhaust_points != null:
			exhaust_points.show()
	else:
		ship.exhaust.hide()
		if exhaust_points != null:
			exhaust_points.hide()


const RADIANS_PER_SECOND: float = PI / 2
