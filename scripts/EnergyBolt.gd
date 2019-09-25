extends RigidBody

var life: float = 5.0 # In seconds
var speed: float = 80.0


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


var DAMAGE_HULL: int = 15
var DAMAGE_SHIELD: int = 10
