extends Spatial

onready var camera = get_node("Camera")

var move_vel: Vector2


func _process(delta):
	var move_acc: Vector2 = Vector2(Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right"), Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down"))

	move_vel = move_vel.linear_interpolate(4 * move_acc, 7 * delta)

	if move_vel.x != 0 or move_vel.y != 0:
		move_position(move_vel)


# PUBLIC


func move_position(vel: Vector2):
	var translate_vel: Vector3 = vel.x * -camera.transform.basis.x + vel.y * camera.transform.basis.y
	translate(TRANSLATE_SPEED * translate_vel)


func orbit(vel: Vector2):
	rotate(transform.basis.x, ROTATION_SPEED * vel.y)
	rotate(Vector3.UP, ROTATION_SPEED * vel.x)


const ROTATION_SPEED: float = 0.02
const TRANSLATE_SPEED: float = 0.02
