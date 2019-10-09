extends Spatial

onready var hardpoints = get_children()

var ammo_capacity: int = 0
var countdown: float = 0
var hardpoint_index: int = 0
var hardpoint_count: int
var weapon
var weapon_name: String = "weapon" # TODO: get the weapon's name when we assign it... somehow


func _ready():
	hardpoint_count = hardpoints.size()


func _process(delta):
	if countdown > 0:
		countdown -= delta

		if countdown <= 0:
			countdown = 0
			emit_signal("countdown_completed")


# PUBLIC


func fire_missile_weapon(ship, target = null):
	var missile = fire_weapon(ship)

	if target != null:
		missile.set_target(target)


func fire_weapon(ship):
	# Instance weapon and make it ignore the ship that fired it
	var weapon_instance = weapon.instance()
	weapon_instance.add_collision_exception_with(ship)
	weapon_instance.owner_ship = ship

	get_tree().get_root().add_child(weapon_instance)
	weapon_instance.transform.origin = hardpoints[hardpoint_index].global_transform.origin

	weapon_instance.look_at(hardpoints[hardpoint_index].global_transform.origin - ship.transform.basis.z, ship.transform.basis.y)
	weapon_instance.add_speed(ship.get_linear_velocity().length())

	countdown = weapon_instance.fire_delay
	hardpoint_index = (hardpoint_index + 1) % hardpoint_count

	return weapon_instance


func get_hardpoint_pos():
	return hardpoints[hardpoint_index].transform.origin


func get_weapon_cost():
	# TODO: figure out how best to get this from the assigned weapon, or how to better assign weapons
	return 1.0


signal countdown_completed
