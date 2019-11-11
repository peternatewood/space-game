extends Spatial

onready var camera = get_node("Camera")


func orbit(vel: Vector2):
	rotate(transform.basis.x, ROTATION_MOD * vel.y)
	rotate(Vector3.UP, ROTATION_MOD * vel.x)


const ROTATION_MOD: float = 0.02
