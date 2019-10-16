extends "res://scripts/ShipBase.gd"

enum ORDER_TYPE { PASSIVE, PATROL, DEFEND, ATTACK, ATTACK_ANY, IGNORE }

export (ORDER_TYPE) var behavior_state = ORDER_TYPE.PASSIVE

var is_flying_at_target: bool = true


func _process(delta):
	if has_target:
		_turn_towards_target(current_target.transform.origin)

		var to_target: Vector3 = current_target.transform.origin - transform.origin
		var target_dist_squared: float = to_target.length_squared()
		if is_flying_at_target:
			if target_dist_squared < MIN_TARGET_DIST_SQ:
				is_flying_at_target = false
			else:
				var desired_throttle: float = _get_throttle_to_match_target_speed()
				throttle = max(desired_throttle, 0.1)
		else:
			if target_dist_squared > MAX_TARGET_DIST_SQ:
				is_flying_at_target = true
			else:
				throttle = (-transform.basis.z).angle_to(to_target) / PI

		if behavior_state != ORDER_TYPE.PASSIVE:
			var raycast_collider = target_raycast.get_collider()
			if raycast_collider == current_target:
				_fire_energy_weapon()
	else:
		# Get closest hostile target
		var closest_distance: float = -1
		var closest_index: int = -1
		var targets = mission_controller.get_targets()

		for index in range(targets.size()):
			if mission_controller.get_alignment(faction, targets[index].faction) == mission_controller.HOSTILE:
				var distance_squared = (targets[index].transform.origin - transform.origin).length_squared()
				if distance_squared < closest_distance or closest_distance == -1:
					closest_distance = distance_squared
					closest_index = index

		if closest_index != -1:
			_set_current_target(targets[closest_index])

	._process(delta)


func _turn_towards_target(target_pos: Vector3):
	var to_target: Vector3 = (target_pos - transform.origin).normalized()

	var x_dot = transform.basis.x.dot(to_target)
	var y_dot = transform.basis.y.dot(to_target)

	if is_flying_at_target:
		# Stop turning if angular vel is high enough
		var angle_to_target: float = (-transform.basis.z).angle_to(to_target)
		if abs(angular_velocity.y) > abs(angle_to_target):
			x_dot /= 2
		if abs(angular_velocity.x) > abs(angle_to_target):
			y_dot /= 2

		torque_vector = transform.basis.x * y_dot - transform.basis.y * x_dot
	else:
		# Turn away to put distance between self and target
		torque_vector = -transform.basis.x * y_dot + transform.basis.y * x_dot


const LINE_OF_FIRE_SQ: float = 4.0 # Squared to make processing faster
const MAX_TARGET_DIST_SQ: float = pow(15, 2)
const MIN_TARGET_DIST_SQ: float = pow(6, 2)
