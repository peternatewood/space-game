extends "res://scripts/TurretBase.gd"

onready var missile_rack = get_node("Missile Rack")
onready var target_raycast = get_node("Missile Rack/Target Raycast")

var hardpoint_index: int = 0
var hardpoint_count: int
var hardpoints: Array = []


func _ready():
	for node in missile_rack.get_children():
		hardpoints.append(node)
		hardpoint_count += 1


func _point_at_target(delta):
	var direct_looking_at = missile_rack.global_transform.looking_at(current_target.transform.origin, global_transform.basis.y)

	var projected = -missile_rack.global_transform.basis.z.project(global_transform.basis.y)
	var on_plane = -missile_rack.global_transform.basis.z - projected
	# Clamp the missile rack's angle if below the minimum angle
	if -direct_looking_at.basis.z.dot(global_transform.basis.y) < 0:
		var to_target = current_target.transform.origin - missile_rack.global_transform.origin
		var direct_projected = to_target.project(global_transform.basis.y)
		var direct_on_plane = to_target - direct_projected
		direct_looking_at = missile_rack.global_transform.looking_at(missile_rack.global_transform.origin + direct_on_plane, global_transform.basis.y)

	missile_rack.global_transform = missile_rack.global_transform.interpolate_with(direct_looking_at, delta * TURN_SPEED)

	# Now adjust the base to line up with the barrel's position
	turret_base.look_at(global_transform.origin + on_plane, global_transform.basis.y)


func _process(delta):
	._process(delta)

	if is_alive:
		if is_target_in_range():
			fire_weapon()


# PUBLIC


func fire_weapon():
	if is_weapon_loaded and fire_countdown <= 0:
		var missile = weapon.instance()
		missile.add_collision_exception_with(self)
		missile.add_collision_exception_with(capital_ship)
		missile.owner_ship = capital_ship

		get_tree().get_root().add_child(missile)

		missile.transform.origin = hardpoints[hardpoint_index].global_transform.origin
		missile.look_at(missile.global_transform.origin - missile_rack.global_transform.basis.z, Vector3.UP)
		missile.add_speed(0.0)

		missile.set_target(current_target)

		fire_countdown += missile.fire_delay

		hardpoint_index = (hardpoint_index + 1) % hardpoint_count


func is_target_in_range():
	if not has_target:
		return false

	var raycast_collider = target_raycast.get_collider()

	return raycast_collider == current_target and .is_target_in_range()


const TURN_SPEED: float = 0.5
