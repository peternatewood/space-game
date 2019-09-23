extends Area

var life: float = 5.0 # In seconds
var speed: float = 25.0


func _process(delta):
	global_translate(delta * speed * -transform.basis.z)

	life -= delta
	if life <= 0:
		queue_free()


# PUBLIC


func add_speed(amount: float):
	speed += amount

