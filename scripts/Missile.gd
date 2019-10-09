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


# Avg speed when accelerating: (max_speed - acceleration) / 2 | Seconds to reach max speed: max_speed / acceleration | Add max speed multiplied by remaining seconds
# Avg accel speed: (100 - 20) / 2 = 40 | Seconds to max speed: 100 / 20 = 5
# 40 * 5 + 100 * (12 - 5)
const RANGE: float = 900.0
