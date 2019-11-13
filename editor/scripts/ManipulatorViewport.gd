extends Viewport

onready var camera = get_node("Camera")


func get_node_at_position(pos: Vector2):
	var ray_origin = camera.project_ray_origin(pos)
	var ray_normal = camera.project_ray_normal(pos)

	var world_state = find_world().get_direct_space_state()

	var intersection = world_state.intersect_ray(ray_origin, ray_origin + 100 * ray_normal, [], 0x7FFFFFFF, false, true)

	if intersection.has("collider"):
		return intersection

	return null


func update_camera(other_camera):
	camera.global_transform = other_camera.camera.global_transform
