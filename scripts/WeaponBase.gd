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


"""
NOTE: weight doesn't matter if gravity is 0
mass: 1.0 | speed: 80 | velocity: 1.33333 | speed/vel: 60
mass: 0.5 | speed: 80 | velocity: 2.66667 | speed/vel: 30
mass: 0.2 | speed: 80 | velocity: 6.66667 | speed/vel: 12
mass: 0.1 | speed: 80 | velocity: 13.3333 | speed/vel: 6

mass: 0.2 | speed: 20 | velocity: 1.66667 | speed/vel: 12

To get the end velocity, divide the speed property by (mass * 60)
"""
