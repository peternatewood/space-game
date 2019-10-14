extends "res://scripts/ShipBase.gd"


func _on_scene_loaded():
	_set_current_target(get_tree().get_root().get_node("Mission Controller/Player"))

	._on_scene_loaded()


func _process(delta):
	if has_target:
		var raycast_collider = target_raycast.get_collider()
		if raycast_collider == current_target:
			_fire_energy_weapon()

	._process(delta)


const LINE_OF_FIRE_SQ: float = 4.0 # Squared to make processing faster
