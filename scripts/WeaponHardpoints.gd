extends Spatial

onready var hardpoints = get_children()

var ammo_capacity: int = 0
var ammo_count: int = 0
var countdown: float = 0
var hardpoint_index: int = 0
var hardpoint_count: int
var is_weapon_loaded: bool = false
var weapon
var weapon_data: Dictionary = {}


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
	ammo_count -= 1
	emit_signal("ammo_count_changed", ammo_count)

	if target != null:
		missile.set_target(target)


func fire_weapon(ship):
	# Instance weapon and make it ignore the ship that fired it
	var weapon_instance = weapon.instance()
	weapon_instance.owner_ship = ship

	get_tree().get_root().add_child(weapon_instance)
	weapon_instance.transform.origin = hardpoints[hardpoint_index].global_transform.origin

	weapon_instance.look_at(ship.get_targeting_endpoint(), ship.transform.basis.y)
	weapon_instance.add_speed(ship.linear_velocity.length())

	countdown = weapon_instance.fire_delay
	hardpoint_index = (hardpoint_index + 1) % hardpoint_count

	return weapon_instance


func get_hardpoint_pos():
	return hardpoints[hardpoint_index].transform.origin


func set_weapon(weapon_scene, missile_capacity = null):
	if weapon_scene == null:
		for name in WEAPON_DATA_NAMES:
			weapon_data[name] = "none"
	else:
		is_weapon_loaded = true
		weapon = weapon_scene

		var weapon_instance = weapon.instance()
		for name in WEAPON_DATA_NAMES:
			if weapon_instance.has_meta(name):
				weapon_data[name] = weapon_instance.get_meta(name)

		if weapon_data.has("ammo_cost") and missile_capacity != null:
			ammo_capacity = round(missile_capacity / weapon_data["ammo_cost"])
			ammo_count = ammo_capacity

		weapon_instance.free()


signal countdown_completed
signal ammo_count_changed

const WEAPON_DATA_NAMES: Array = [
	"ammo_cost",
	"cost",
	"firing_range",
	"speed",
	"weapon_name"
]
