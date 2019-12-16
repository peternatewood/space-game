extends "res://scripts/ShipBase.gd"

enum { COCKPIT, CHASE }

var allow_input: bool = false
var cam_dist: float
var cam_mode: int
var cam_offset: Vector3
var camera
var input_velocity: Vector3


func _ready():
	if has_warp_ramp_up:
		self.connect("warping_ramped_up", warp_ramp_up_player, "stop")

	._ready()


func _start_destruction():
	# Move camera to exterior position
	camera.transform.origin = transform.origin + 5 * Vector3(randf(), randf(), randf()).normalized()
	camera.look_at(transform.origin, Vector3.UP)

	._start_destruction()


func _input(event):
	if allow_input and is_alive:
		if event.is_action("change_cam") and event.pressed:
			match cam_mode:
				COCKPIT:
					_set_cam_mode(CHASE)
				CHASE:
					_set_cam_mode(COCKPIT)
		elif event.is_action("warp_out") and event.pressed:
			if warping == NONE:
				warp_out()
		elif event.is_action("throttle_up") and event.pressed:
			throttle = min(MAX_THROTTLE, throttle + ACCELERATION)
			emit_signal("throttle_changed")
		elif event.is_action("throttle_down") and event.pressed:
			throttle = max(0, throttle - ACCELERATION)
			emit_signal("throttle_changed")
		elif event.is_action("set_throttle_zero") and event.pressed:
			throttle = 0
			emit_signal("throttle_changed")
		elif event.is_action("set_throttle_full") and event.pressed:
			throttle = MAX_THROTTLE
			emit_signal("throttle_changed")
		# Targeting
		elif event.is_action("deselect_target") and event.pressed:
			has_target = false
			emit_signal("target_changed", current_target)
			current_target = null
		elif event.is_action("target_next_hostile") and event.pressed:
			var last_target
			if has_target:
				last_target = current_target

			if _target_next_of_alignment(mission_controller.HOSTILE):
				has_target = true
				emit_signal("target_changed", last_target)
		elif event.is_action("target_next_friendly") and event.pressed:
			var last_target
			if has_target:
				last_target = current_target

			if _target_next_of_alignment(mission_controller.FRIENDLY):
				has_target = true
				emit_signal("target_changed", last_target)
		elif event.is_action("target_next_neutral") and event.pressed:
			var last_target
			if has_target:
				last_target = current_target

			if _target_next_of_alignment(mission_controller.NEUTRAL):
				has_target = true
				emit_signal("target_changed", last_target)
		elif event.is_action("target_next_in_reticule") and event.pressed:
			var targets_in_view: Array = []
			for target in mission_controller.get_targets():
				if camera.is_position_in_view(target.transform.origin):
					targets_in_view.append(target)

			var last_target
			if targets_in_view.size() != 0:
				if has_target:
					last_target = current_target
					target_index = (target_index + 1) % targets_in_view.size()

				_set_current_target(targets_in_view[target_index])

			emit_signal("target_changed", last_target)
		elif event.is_action("target_next") and event.pressed:
			var targets = mission_controller.get_targets()
			var last_target
			# One or less since the player is included in the targets collection
			if targets.size() <= 1:
				has_target = false
				current_target = null
			else:
				if has_target:
					last_target = current_target
					target_index = (target_index + 1) % targets.size()

				if targets[target_index] == self:
					target_index = (target_index + 1) % targets.size()

				_set_current_target(targets[target_index])

			emit_signal("target_changed", last_target)
		elif event.is_action("deselect_subsystem") and event.pressed:
			_deselect_target_subsystem()
		elif event.is_action("target_subsystem") and event.pressed:
			_cycle_target_subsystems()
		# Shield Boosting/Redirecting
		elif event.is_action("boost_shield_front") and event.pressed:
			ShieldQuadrant.boost_shield_quadrant(shields, FRONT)
			emit_signal("shield_boost_changed")
		elif event.is_action("boost_shield_rear") and event.pressed:
			ShieldQuadrant.boost_shield_quadrant(shields, REAR)
			emit_signal("shield_boost_changed")
		elif event.is_action("boost_shield_left") and event.pressed:
			ShieldQuadrant.boost_shield_quadrant(shields, LEFT)
			emit_signal("shield_boost_changed")
		elif event.is_action("boost_shield_right") and event.pressed:
			ShieldQuadrant.boost_shield_quadrant(shields, RIGHT)
			emit_signal("shield_boost_changed")
		elif event.is_action("clear_shield_boost") and event.pressed:
			ShieldQuadrant.boost_shield_quadrant(shields, -1)
			emit_signal("shield_boost_changed")
		elif event.is_action("redirect_shield_to_front") and event.pressed:
			ShieldQuadrant.redirect_hitpoints_to_quadrant(shields, FRONT)
		elif event.is_action("redirect_shield_to_rear") and event.pressed:
			ShieldQuadrant.redirect_hitpoints_to_quadrant(shields, REAR)
		elif event.is_action("redirect_shield_to_left") and event.pressed:
			ShieldQuadrant.redirect_hitpoints_to_quadrant(shields, LEFT)
		elif event.is_action("redirect_shield_to_right") and event.pressed:
			ShieldQuadrant.redirect_hitpoints_to_quadrant(shields, RIGHT)
		elif event.is_action("equalize_shields") and event.pressed:
			ShieldQuadrant.equalize_shields(shields)
		# System power distribution
		elif event.is_action("increment_weapon_power") and event.pressed:
			_increment_power_level(WEAPON, 1)
			emit_signal("power_distribution_changed")
		elif event.is_action("decrement_weapon_power") and event.pressed:
			_increment_power_level(WEAPON, -1)
			emit_signal("power_distribution_changed")
		elif event.is_action("increment_shield_power") and event.pressed:
			_increment_power_level(SHIELD, 1)
			emit_signal("power_distribution_changed")
		elif event.is_action("decrement_shield_power") and event.pressed:
			_increment_power_level(SHIELD, -1)
			emit_signal("power_distribution_changed")
		elif event.is_action("increment_engine_power") and event.pressed:
			_increment_power_level(ENGINE, 1)
			emit_signal("power_distribution_changed")
		elif event.is_action("decrement_engine_power") and event.pressed:
			_increment_power_level(ENGINE, -1)
			emit_signal("power_distribution_changed")
		elif event.is_action("equalize_power") and event.pressed:
			power_distribution[WEAPON] = TOTAL_SYSTEM_POWER / 3
			power_distribution[SHIELD] = TOTAL_SYSTEM_POWER / 3
			power_distribution[ENGINE] = TOTAL_SYSTEM_POWER / 3

			emit_signal("power_distribution_changed")
		# Weapons stuff
		elif event.is_action("cycle_energy_weapon") and event.pressed:
			_cycle_energy_weapon(1)
			emit_signal("energy_weapon_changed")
		elif event.is_action("cycle_missile_weapon") and event.pressed:
			_cycle_missile_weapon(1)
			emit_signal("missile_weapon_changed")


func _on_fov_changed(value: int):
	camera.set_fov(value)


func _on_mission_ready():
	camera = get_viewport().get_camera()
	camera.set_fov(settings.get_fov())
	settings.connect("fov_changed", self, "_on_fov_changed")
	_set_cam_mode(COCKPIT)

	._on_mission_ready()

	allow_input = true


func _process(delta):
	match warping:
		NONE:
			if is_alive:
				input_velocity.x = Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down")
				input_velocity.y = Input.get_action_strength("yaw_left") - Input.get_action_strength("yaw_right")
				input_velocity.z = Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right")

				torque_vector = transform.basis.x * input_velocity.x + transform.basis.y * input_velocity.y + transform.basis.z * input_velocity.z

				if Input.is_action_pressed("fire_energy_weapon"):
					_fire_energy_weapon()

				if Input.is_action_pressed("fire_missile_weapon"):
					if has_target:
						_fire_missile_weapon(current_target)
					else:
						_fire_missile_weapon()

				match cam_mode:
					COCKPIT:
						camera.transform.origin = cockpit_view.global_transform.origin
						camera.look_at(cockpit_view.global_transform.origin - 5 * transform.basis.z, transform.basis.y)
					CHASE:
						cam_offset = cam_offset.linear_interpolate(input_velocity, delta)
						cam_dist = lerp(cam_dist, throttle * CAM_THROTTLE_MOD, delta)
						var cam_up = transform.basis.y + transform.basis.x * CAM_ROLL_MOD * cam_offset.z

						camera.transform.origin = chase_view.global_transform.origin - transform.basis.x * cam_offset.y + transform.basis.y * cam_offset.x + transform.basis.z * cam_dist
						camera.look_at(transform.origin - transform.basis.z, cam_up)
			else:
				camera.look_at(transform.origin, Vector3.UP)

		WARP_OUT:
			camera.look_at(transform.origin, transform.basis.y)

	._process(delta)


func _set_cam_mode(mode: int):
	match mode:
		COCKPIT:
			cam_mode = COCKPIT
			_toggle_ship_mesh(false)
		CHASE:
			cam_mode = CHASE
			_toggle_ship_mesh(true)

	emit_signal("cam_changed", cam_mode)


func _toggle_ship_mesh(show_meshes: bool):
	for child in get_children():
		if child is MeshInstance:
			if show_meshes:
				child.show()
			else:
				child.hide()


# PUBLIC


func warp_out():
	# Allow physics to bring player to a full stop
	torque_vector = Vector3.ZERO

	# Move camera to a roughly random position behind the player
	_toggle_ship_mesh(true)
	camera.transform.origin = transform.origin + 4 * ((randi() % 2) - 0.5) * transform.basis.x + 2 * transform.basis.y + 2 * transform.basis.z

	if has_warp_ramp_up:
		warp_ramp_up_player.play()
	else:
		print("Missing warp ramp up sound")

	warp(false)

	emit_signal("began_warp_out")


signal cam_changed
signal power_distribution_changed
signal shield_boost_changed
signal target_changed
signal throttle_changed
signal began_warp_out

#const ShipBase = preload("ShipBase.gd")

const CAM_ROLL_MOD: float = 0.25
const CAM_THROTTLE_MOD: float = 1.5
