extends "res://scripts/ShipBase.gd"

enum ORDER_TYPE { PASSIVE, ATTACK, DEFEND, IGNORE, ATTACK_ANY, DEPART, ARRIVE, PATROL, COVER_ME }

export (Array, ORDER_TYPE) var initial_orders = [
	ORDER_TYPE.PASSIVE,
	ORDER_TYPE.PASSIVE,
	ORDER_TYPE.PASSIVE,
	ORDER_TYPE.PASSIVE,
	ORDER_TYPE.PASSIVE,
	ORDER_TYPE.PASSIVE
]

var defend_target
var is_flying_at_target: bool = true
var orders: Array = []
var waypoint_pos: Vector3
var waypoint_index: int = -1


func _defended_target_destroyed(order_index):
	orders[order_index].target = null
	orders[order_index].type = ORDER_TYPE.PASSIVE


func _attack_current_target():
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

	var raycast_collider = target_raycast.get_collider()
	if raycast_collider == current_target:
		_fire_energy_weapon()


func _get_next_waypoint():
	waypoint_index = (waypoint_index + 1) % mission_controller.waypoints.size()
	waypoint_pos = mission_controller.get_next_waypoint_pos(waypoint_index)


func _on_mission_ready():
	for order_type in initial_orders:
		var order = Order.new(order_type)
		orders.append(order)

		match order_type:
			ORDER_TYPE.ARRIVE:
				# TODO: Provide a way to specify arrival delay
				var warp_in_timer = Timer.new()
				warp_in_timer.set_one_shot(true)
				warp_in_timer.set_autostart(true)
				warp_in_timer.set_wait_time(2)
				warp_in_timer.connect("timeout", self, "warp", [ true ])
				get_tree().get_root().add_child(warp_in_timer)
				order.type = ORDER_TYPE.PASSIVE

	._on_mission_ready()


func _on_target_destroyed():
	if orders[0].target == current_target:
		orders[0].target = null
		orders[0].type = ORDER_TYPE.PASSIVE

	._on_target_destroyed()


func _process(delta):
	if warping == NONE:
		for o in orders:
			match o.type:
				ORDER_TYPE.PATROL:
					if waypoint_index == -1:
						_get_next_waypoint()
					else:
						var dist_squared = (waypoint_pos - transform.origin).length_squared()
						if dist_squared <= 1:
							_get_next_waypoint()
						else:
							_turn_towards_target(waypoint_pos)

						if throttle != PATROL_THROTTLE:
							throttle = PATROL_THROTTLE
				ORDER_TYPE.ATTACK:
					if has_target:
						_attack_current_target()
					else:
						_set_current_target(o.target)
				ORDER_TYPE.DEFEND, ORDER_TYPE.COVER_ME:
					# NOTE: when switching to a DEFEND order, the ship should untarget whatever it's currently targeting
					if has_target:
						_attack_current_target()
					else:
						var closest_target = mission_controller.get_closest_target(self, o.target.targeting_ships, mission_controller.HOSTILE)
						if closest_target != null:
							_set_current_target(closest_target)
						else:
							o.type = ORDER_TYPE.PASSIVE
				ORDER_TYPE.IGNORE:
					if has_target and current_target == o.target:
						_deselect_current_target()
				ORDER_TYPE.ATTACK_ANY:
					if has_target:
						_attack_current_target()
					else:
						# Get closest hostile target
						var closest_target = mission_controller.get_closest_target(self, mission_controller.get_targets(), mission_controller.HOSTILE)
						if closest_target != null:
							_set_current_target(closest_target)
						else:
							o.type = ORDER_TYPE.PASSIVE
				ORDER_TYPE.DEPART:
					warp(false)

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


# PUBLIC


# Return true if command successful, false if unable to comply for whatever reason
func set_command(command: int, commander):
	var alignment: int = mission_controller.get_alignment(faction, commander.faction)
	var target_alignment: int = -1
	var new_order = Order.new(command)

	if commander.has_target:
		target_alignment = mission_controller.get_alignment(faction, commander.current_target.faction)
		new_order.target = commander.current_target
	else:
		new_order.target = commander

	match command:
		ORDER_TYPE.ATTACK:
			if not commander.has_target:
				print("No target selected!")
				return false
			elif target_alignment == mission_controller.FRIENDLY:
				print("Cannot attack a friendly target!")
				return false
		ORDER_TYPE.DEFEND:
			if not commander.has_target:
				print("No target selected!")
				return false
			elif target_alignment == mission_controller.HOSTILE:
				print("Cannot defend a hostile target!")
				return false
			else:
				commander.current_target.connect("destroyed", self, "_defended_target_destroyed", [ 0 ])
				commander.current_target.connect("warped_out", self, "_defended_target_destroyed", [ 0 ])
		ORDER_TYPE.IGNORE:
			if not commander.has_target:
				print("No target selected!")
				return false
		ORDER_TYPE.COVER_ME:
			if alignment == mission_controller.HOSTILE:
				print("Cannot cover a hostile target!")
				return false
		ORDER_TYPE.DEPART:
			warp(false)
			return true

	orders[0] = new_order
	return true


const LINE_OF_FIRE_SQ: float = 4.0 # Squared to make processing faster
const MAX_TARGET_DIST_SQ: float = pow(15, 2)
const MIN_TARGET_DIST_SQ: float = pow(6, 2)
const PATROL_THROTTLE: float = 0.7


class Order:
	var priority: int
	var target
	var type: int


	func _init(order_type: int, order_target = null, order_priority: int = 50):
		priority = order_priority
		target = order_target
		type = order_type
