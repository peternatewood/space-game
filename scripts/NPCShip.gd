extends "res://scripts/ShipBase.gd"

var behavior_state: int = PASSIVE


func _on_scene_loaded():
	_set_current_target(get_tree().get_root().get_node("Mission Controller/Player"))

	._on_scene_loaded()


func _process(delta):
	if has_target:
		_turn_towards_target(delta)

		if behavior_state != PASSIVE:
			var raycast_collider = target_raycast.get_collider()
			if raycast_collider == current_target:
				_fire_energy_weapon()
	else:
		# TODO: find a target, patrol, or do something else
		pass

	._process(delta)


func _turn_towards_target(delta):
	var to_target = (current_target.transform.origin - transform.origin).normalized()
	var x_dot = transform.basis.x.dot(to_target)
	var y_dot = transform.basis.y.dot(to_target)

	torque_vector = transform.basis.x * y_dot - transform.basis.y * x_dot


enum { PASSIVE, PATROL, DEFEND, ATTACK }

const LINE_OF_FIRE_SQ: float = 4.0 # Squared to make processing faster
