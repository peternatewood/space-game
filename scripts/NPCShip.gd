extends "res://scripts/ShipBase.gd"


func _is_target_in_range():
	var to_target = current_target.transform.origin - transform.origin
	var dot_product = -transform.basis.z.dot(to_target)

	if dot_product <= 0:
		return false

	var target_distance_sq = to_target.length_squared()
	var angle_to = -transform.basis.z.angle_to(to_target)
	var distance_from_center = abs(sin(angle_to) * target_distance_sq)

	return distance_from_center <= LINE_OF_FIRE_SQ and target_distance_sq <= pow(_get_energy_weapon_range(), 2)


func _on_scene_loaded():
	_set_current_target(get_tree().get_root().get_node("Scene/Player"))

	._on_scene_loaded()


func _process(delta):
	if has_target and _is_target_in_range():
			_fire_energy_weapon()

	._process(delta)


const LINE_OF_FIRE_SQ: float = 4.0 # Squared to make processing faster
