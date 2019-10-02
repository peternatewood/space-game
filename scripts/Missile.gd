extends "res://scripts/MissileBase.gd"


func _ready():
	acceleration = 20.0
	damage_hull = 25
	damage_shield = 5
	fire_delay = 1.0
	life = 12.0
	max_speed = 100.0
	speed = 0.0
	turn_speed = 1.5


func _process(delta):
	if has_target:
		var to_target = target.transform.origin - transform.origin
		var dot_product = -transform.basis.z.dot(to_target)

		if dot_product < 0:
			_on_target_destroyed()
		else:
			transform = transform.interpolate_with(transform.looking_at(target.transform.origin, Vector3.UP), delta * turn_speed)

	if speed < max_speed:
		speed = min(max_speed, speed + delta * acceleration)

	translate(delta * speed * Vector3.FORWARD)

	._process(delta)
