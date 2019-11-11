extends Spatial

onready var camera = get_node("Camera")


func move_position(vel: Vector2):
	var translate_vel: Vector3 = vel.x * -camera.transform.basis.x + vel.y * camera.transform.basis.y
	translate(TRANSLATE_SPEED * translate_vel)


func orbit(vel: Vector2):
	rotate(transform.basis.x, ROTATION_SPEED * vel.y)
	rotate(Vector3.UP, ROTATION_SPEED * vel.x)


const ROTATION_SPEED: float = 0.02
const TRANSLATE_SPEED: float = 0.02
