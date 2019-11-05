extends "res://scripts/TurretBase.gd"

onready var barrels = get_node("Barrels")

var hardpoint_index: int = 0
var hardpoint_count: int
var hardpoints: Array = []


func _ready():
	for node in barrels.get_children():
		hardpoints.append(node)
		hardpoint_count += 1


# PUBLIC


func fire_weapon(ship):
	if is_weapon_loaded and fire_countdown <= 0:
		var bolt = weapon.instance()
		bolt.add_collision_exception_with(self)
		bolt.add_collision_exception_with(ship)
		bolt.owner_ship = ship

		get_tree().get_root().add_child(bolt)

		bolt.transform.origin = hardpoints[hardpoint_index].global_transform.origin
		bolt.look_at(bolt.global_transform.origin + barrels.global_transform.basis.y, Vector3.UP)
		bolt.add_speed(0.0)

		fire_countdown += bolt.fire_delay

		hardpoint_index = (hardpoint_index + 1) % hardpoint_count
