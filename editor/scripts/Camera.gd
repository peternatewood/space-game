extends Spatial

onready var camera = get_node("Camera")

var move_vel: Vector2


func _process(delta):
	var move_acc: Vector2 = Vector2(Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right"), Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down"))

	move_vel = move_vel.linear_interpolate(4 * move_acc, 7 * delta)

	if move_vel.x != 0 or move_vel.y != 0:
		move_position(move_vel)


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


func zoom_in():
	camera.transform.origin.z = camera.transform.origin.z / ZOOM_SPEED


func zoom_out():
	camera.transform.origin.z = camera.transform.origin.z * ZOOM_SPEED


const ROTATION_SPEED: float = 0.02
const TRANSLATE_SPEED: float = 0.02
const ZOOM_SPEED: float = 1.1
