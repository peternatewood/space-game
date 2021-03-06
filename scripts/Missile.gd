extends "res://scripts/WeaponBase.gd"

export (float) var acceleration = 0.0
export (float) var ammo_cost = 0.0
export (float) var max_speed = 0.0
export (float) var search_radius = 0.0
export (float) var turn_speed = 0.0

var has_target: bool = false
var searched_for_target: bool = false
var target


func _on_target_destroyed():
	has_target = false
	target = null


func _process(delta):
	if has_target:
		if not searched_for_target:
			searched_for_target = true

		var to_target = target.transform.origin - transform.origin
		var dot_product = -transform.basis.z.dot(to_target)

		if dot_product < 0:
			_on_target_destroyed()
		else:
			transform = transform.interpolate_with(transform.looking_at(target.transform.origin, Vector3.UP), delta * turn_speed)
	elif not searched_for_target:
		# If fired without a target, search for one within the search_area node
		var closest_index: int = -1
		var shortest_distance: float = -1.0
		var targets = mission_controller.get_targets()
		for index in range(targets.size()):
			if targets[index] != owner_ship:
				var to_target: Vector3 = targets[index].transform.origin - transform.origin
				var dist_squared: float = to_target.length_squared()
				var dot_product: float = (-transform.basis.z).dot(to_target.normalized())

				# Only consider objects within a cone of vision
				if dot_product > 0.85 and (dist_squared < shortest_distance or shortest_distance == -1):
					shortest_distance = dist_squared
					closest_index = index

		if closest_index != -1:
			set_target(targets[closest_index])

		# Whether we found a target or not, don't search again
		searched_for_target = true

	if speed < max_speed:
		speed = min(max_speed, speed + delta * acceleration)

	._process(delta)


# PUBLIC


func add_speed(amount: float):
	speed += amount


func set_target(node):
	has_target = true
	target = node
	target.connect("destroyed", self, "_on_target_destroyed")
	target.connect("warped_out", self, "_on_target_destroyed")
