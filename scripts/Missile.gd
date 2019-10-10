extends "res://scripts/MissileBase.gd"


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
