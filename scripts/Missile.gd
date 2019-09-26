extends RigidBody

var has_target: bool = false
var life: float = 12.0 # In seconds
var speed: float = 0.0
var target


func _on_target_destroyed():
	has_target = false
	target = null


func _process(delta):
	life -= delta
	if life <= 0:
		queue_free()

	if has_target:
		var to_target = target.transform.origin - transform.origin
		var dot_product = -transform.basis.z.dot(to_target)

		if dot_product < 0:
			_on_target_destroyed()
		else:
			transform = transform.interpolate_with(transform.looking_at(target.transform.origin, Vector3.UP), delta)

	if speed < MAX_SPEED:
		speed = min(MAX_SPEED, speed + delta * ACCELERATION)

	translate(delta * speed * Vector3.FORWARD)


# PUBLIC


func add_speed(amount: float):
	speed += amount


func destroy():
	queue_free()


func set_target(node):
	has_target = true
	target = node
	target.connect("destroyed", self, "_on_target_destroyed")


var ACCELERATION: float = 20.0
var DAMAGE_HULL: int = 25
var DAMAGE_SHIELD: int = 5
var MAX_SPEED: float = 100.0
var TURN_SPEED: float = 0.2
