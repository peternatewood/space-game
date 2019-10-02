extends "res://scripts/ShipBase.gd"

export (NodePath) var camera_path

onready var chase_view = get_node("Chase View")
onready var cockpit_view = get_node("Cockpit View")
onready var enemies_container = get_tree().get_root().get_node("Scene/Enemies Container")

var cam_dist: float
var cam_mode: int
var cam_offset: Vector3
var camera
var current_target
var has_target: bool = false
var input_velocity: Vector3
var target_index: int = 0


func _input(event):
	if event.is_action("change_cam") and event.pressed:
		match cam_mode:
			COCKPIT:
				_set_cam_mode(CHASE)
			CHASE:
				_set_cam_mode(COCKPIT)
	elif event.is_action("throttle_up") and event.pressed:
		throttle = min(MAX_THROTTLE, throttle + ACCELERATION)
		emit_signal("throttle_changed", throttle)
	elif event.is_action("throttle_down") and event.pressed:
		throttle = max(0, throttle - ACCELERATION)
		emit_signal("throttle_changed", throttle)
	elif event.is_action("target_next") and event.pressed:
		var enemies = enemies_container.get_children()
		if enemies.size() == 0:
			has_target = false
			current_target = null
		else:
			if has_target:
				current_target.disconnect("destroyed", self, "_on_target_destroyed")

			has_target = true
			current_target = enemies[target_index]
			target_index = (target_index + 1) % enemies.size()
			current_target.connect("destroyed", self, "_on_target_destroyed")


func _on_scene_loaded():
	camera = get_node(camera_path)
	_set_cam_mode(COCKPIT)

	._on_scene_loaded()


func _on_target_destroyed():
	has_target = false
	current_target = null
	target_index = 0


func _process(delta):
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

	._process(delta)


func _set_cam_mode(mode: int):
	match mode:
		COCKPIT:
			cam_mode = COCKPIT
			hide()
		CHASE:
			cam_mode = CHASE
			show()


signal throttle_changed

enum { COCKPIT, CHASE }

const CAM_ROLL_MOD: float = 0.25
const CAM_THROTTLE_MOD: float = 1.5
