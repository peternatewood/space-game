extends RigidBody

var damage_hull: int = 15
var damage_shield: int = 10
var fire_delay: float = 0.3 # In seconds
var life: float = 5.0 # In seconds
var owner_ship
var speed: float = 80.0


func _process(delta):
	life -= delta
	if life <= 0:
		queue_free()


# PUBLIC


func destroy():
	queue_free()
