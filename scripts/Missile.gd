extends RigidBody

var life: float = 12.0 # In seconds
var speed: float = 65.0


func _process(delta):
	life -= delta
	if life <= 0:
		queue_free()


# PUBLIC


func add_speed(amount: float):
	speed += amount
	add_central_force(speed * -transform.basis.z)


func destroy():
	queue_free()


var DAMAGE_HULL: int = 25
var DAMAGE_SHIELD: int = 5
