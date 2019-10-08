extends "res://scripts/ShipBase.gd"

export (NodePath) var camera_path

onready var chase_view = get_node("Chase View")
onready var cockpit_view = get_node("Cockpit View")
onready var targets_container = get_tree().get_root().get_node("Mission Controller/Targets Container")

var cam_dist: float
var cam_mode: int
var cam_offset: Vector3
var camera
var input_velocity: Vector3


func _ready():
	var debris = DEBRIS_PARTICLES.instance()
	add_child(debris)
	destruction_delay = 2.0


func _start_destruction():
	# Move camera to exterior position
	camera.transform.origin = transform.origin + 5 * Vector3(randf(), randf(), randf()).normalized()
	camera.look_at(transform.origin, Vector3.UP)

	._start_destruction()


func _input(event):
	if is_alive:
		if event.is_action("change_cam") and event.pressed:
			match cam_mode:
				COCKPIT:
					_set_cam_mode(CHASE)
				CHASE:
					_set_cam_mode(COCKPIT)
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
		elif event.is_action("deselect_target") and event.pressed:
			has_target = false
			emit_signal("target_changed", current_target)
			current_target = null
		elif event.is_action("target_next_hostile") and event.pressed:
			var last_target
			if has_target:
				last_target = current_target

			if _target_next_of_alignment(targets_container.get_children(), mission_controller.HOSTILE):
				has_target = true
				emit_signal("target_changed", last_target)
		elif event.is_action("target_next_friendly") and event.pressed:
			var last_target
			if has_target:
				last_target = current_target

			if _target_next_of_alignment(targets_container.get_children(), mission_controller.FRIENDLY):
				has_target = true
				emit_signal("target_changed", last_target)
		elif event.is_action("target_next_neutral") and event.pressed:
			var last_target
			if has_target:
				last_target = current_target

			if _target_next_of_alignment(targets_container.get_children(), mission_controller.NEUTRAL):
				has_target = true
				emit_signal("target_changed", last_target)
		elif event.is_action("target_next") and event.pressed:
			var targets = targets_container.get_children()
			var last_target
			if targets.size() == 0:
				has_target = false
				current_target = null
			else:
				if has_target:
					last_target = current_target
					target_index = (target_index + 1) % targets.size()

				_set_current_target(targets[target_index])

			emit_signal("target_changed", last_target)
		elif event.is_action("increment_weapon_power") and event.pressed:
			_increment_power_level(ShipBase.WEAPON, 1)
			emit_signal("power_distribution_changed")
		elif event.is_action("decrement_weapon_power") and event.pressed:
			_increment_power_level(ShipBase.WEAPON, -1)
			emit_signal("power_distribution_changed")
		elif event.is_action("increment_shield_power") and event.pressed:
			_increment_power_level(ShipBase.SHIELD, 1)
			emit_signal("power_distribution_changed")
		elif event.is_action("decrement_shield_power") and event.pressed:
			_increment_power_level(ShipBase.SHIELD, -1)
			emit_signal("power_distribution_changed")
		elif event.is_action("increment_engine_power") and event.pressed:
			_increment_power_level(ShipBase.ENGINE, 1)
			emit_signal("power_distribution_changed")
		elif event.is_action("decrement_engine_power") and event.pressed:
			_increment_power_level(ShipBase.ENGINE, -1)
			emit_signal("power_distribution_changed")
		elif event.is_action("equalize_power") and event.pressed:
			power_distribution[WEAPON] = TOTAL_SYSTEM_POWER / 3
			power_distribution[SHIELD] = TOTAL_SYSTEM_POWER / 3
			power_distribution[ENGINE] = TOTAL_SYSTEM_POWER / 3

			emit_signal("power_distribution_changed")


func _on_scene_loaded():
	camera = get_node(camera_path)
	_set_cam_mode(COCKPIT)

	._on_scene_loaded()


func _process(delta):
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
				camera.look_at(transform.origin - 5 * transform.basis.z, transform.basis.y)
			CHASE:
				cam_offset = cam_offset.linear_interpolate(input_velocity, delta)
				cam_dist = lerp(cam_dist, throttle * CAM_THROTTLE_MOD, delta)
				var cam_up = transform.basis.y + transform.basis.x * CAM_ROLL_MOD * cam_offset.z

				camera.transform.origin = chase_view.global_transform.origin - transform.basis.x * cam_offset.y + transform.basis.y * cam_offset.x + transform.basis.z * cam_dist
				camera.look_at(transform.origin - transform.basis.z, cam_up)
	else:
		camera.look_at(transform.origin, Vector3.UP)

	._process(delta)


func _set_cam_mode(mode: int):
	match mode:
		COCKPIT:
			cam_mode = COCKPIT
			_toggle_ship_mesh(false)
		CHASE:
			cam_mode = CHASE
			_toggle_ship_mesh(true)


func _toggle_ship_mesh(show_meshes: bool):
	for child in get_children():
		if child is MeshInstance:
			if show_meshes:
				child.show()
			else:
				child.hide()


signal power_distribution_changed
signal target_changed
signal throttle_changed

enum { COCKPIT, CHASE }

const ShipBase = preload("ShipBase.gd")

const CAM_ROLL_MOD: float = 0.25
const CAM_THROTTLE_MOD: float = 1.5
const DEBRIS_PARTICLES = preload("res://models/Debris_Particles.tscn")
