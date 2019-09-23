extends RigidBody

export (NodePath) var camera_path

onready var camera = get_node(camera_path)
onready var chase_view = get_node("Chase View")
onready var cockpit_view = get_node("Cockpit View")

var cam_dist: float
var cam_mode: int
var cam_offset: Vector3
var input_velocity: Vector3
var throttle: float


func _ready():
	_set_cam_mode(COCKPIT)


func _input(event):
	if event.is_action("change_cam") and event.pressed:
		match cam_mode:
			COCKPIT:
				_set_cam_mode(CHASE)
			CHASE:
				_set_cam_mode(COCKPIT)
	elif event.is_action("throttle_up") and event.pressed:
		throttle = min(MAX_THROTTLE, throttle + ACCELERATION)
	elif event.is_action("throttle_down") and event.pressed:
		throttle = max(0, throttle - ACCELERATION)


func _physics_process(delta):
	input_velocity.x = Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down")
	input_velocity.y = Input.get_action_strength("yaw_left") - Input.get_action_strength("yaw_right")
	input_velocity.z = Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right")

	var torque_vector: Vector3 = transform.basis.x * input_velocity.x + transform.basis.y * input_velocity.y + transform.basis.z * input_velocity.z
	add_torque(TURN_SPEED * torque_vector)

	apply_central_impulse(throttle * -transform.basis.z)


func _process(delta):
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


func _set_cam_mode(mode: int):
	match mode:
		COCKPIT:
			cam_mode = COCKPIT
			hide()
		CHASE:
			cam_mode = CHASE
			show()


enum { COCKPIT, CHASE }

const ACCELERATION: float = 0.1
const CAM_ROLL_MOD: float = 0.25
const CAM_THROTTLE_MOD: float = 1.5
const MAX_THROTTLE: float = 1.0
const TURN_SPEED: float = 2.5
