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


func _physics_process(delta):
	input_velocity.x = Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down")
	input_velocity.y = Input.get_action_strength("yaw_left") - Input.get_action_strength("yaw_right")
	input_velocity.z = Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right")

	var torque_vector: Vector3 = transform.basis.x * input_velocity.x + transform.basis.y * input_velocity.y + transform.basis.z * input_velocity.z
	add_torque(TURN_SPEED * torque_vector)


func _process(delta):
	match cam_mode:
		COCKPIT:
			camera.transform.origin = cockpit_view.global_transform.origin
			camera.look_at(transform.origin - 5 * transform.basis.z, transform.basis.y)
		CHASE:
			camera.transform.origin = chase_view.global_transform.origin
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

const TURN_SPEED: float = 2.5
