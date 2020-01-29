extends Spatial

onready var camera = get_node("Camera")


# PUBLIC


func get_node_at_position(pos: Vector2):
	# TODO: for some reason, we don't get intersections outside of a relatively small region near the center of the viewport
	var ray_origin = camera.project_ray_origin(pos)
	var ray_normal = camera.project_ray_normal(pos)

	var world_state = get_viewport().find_world().get_direct_space_state()

	var intersection = world_state.intersect_ray(ray_origin, ray_origin + 1000 * ray_normal, [ self ], 0x7FFFFFFF, true, false)

	if intersection.has("collider"):
		return intersection.collider

	return null


func move_position(vel: Vector2):
	var translate_vel: Vector3 = vel.x * -camera.transform.basis.x + vel.y * camera.transform.basis.y
	translate(TRANSLATE_SPEED * translate_vel)


func orbit(vel: Vector2):
	rotate(transform.basis.x, ROTATION_SPEED * vel.y)
	rotate(Vector3.UP, ROTATION_SPEED * vel.x)


func reset():
	camera.transform.origin = INITIAL_POSITION
	transform.origin = Vector3.ZERO
	set_rotation_degrees(Vector3(-45, 0, 0))


func zoom_in():
	camera.transform.origin.z = camera.transform.origin.z / ZOOM_SPEED


func zoom_out():
	camera.transform.origin.z = camera.transform.origin.z * ZOOM_SPEED


const INITIAL_POSITION: Vector3 = Vector3(0, 0, 10)
const ROTATION_SPEED: float = 0.02
const TRANSLATE_SPEED: float = 0.02
const ZOOM_SPEED: float = 1.1
