extends "res://scripts/ShipBase.gd"

enum { WEAPON, SHIELD, ENGINE, TOTAL_POWER_LEVELS }
enum { FRONT, REAR, LEFT, RIGHT }

export (String) var wing_name

onready var chase_view = get_node("Chase View")
onready var cockpit_view = get_node("Cockpit View")
onready var energy_weapon_hardpoints = get_node("Energy Weapon Groups").get_children()
onready var shields: Array = [
	get_node("Shield Front"),
	get_node("Shield Rear"),
	get_node("Shield Left"),
	get_node("Shield Right")
]
onready var missile_weapon_hardpoints = get_node("Missile Weapon Groups").get_children()
onready var target_raycast = get_node("Target Raycast")

var energy_weapon_index: int = 0
var missile_weapon_index: int = 0
var power_distribution: Array = [
	float(TOTAL_SYSTEM_POWER / 3),
	float(TOTAL_SYSTEM_POWER / 3),
	float(TOTAL_SYSTEM_POWER / 3)
]
var weapon_battery: float = MAX_WEAPON_BATTERY


func _ready():
	var shield_hitpoints = get_meta("shield_hitpoints")
	for quadrant in shields:
		quadrant.set_max_hitpoints(shield_hitpoints)
		quadrant.set_recovery_rate(power_distribution[SHIELD] / MAX_SYSTEM_POWER)


func _cycle_energy_weapon(direction: int):
	energy_weapon_index = (energy_weapon_index + direction) % energy_weapon_hardpoints.size()

	# Skip any weapon slot that has no weapon loaded
	var index: int = 0
	while not energy_weapon_hardpoints[energy_weapon_index].is_weapon_loaded and index < energy_weapon_hardpoints.size():
		energy_weapon_index = (energy_weapon_index + direction) % energy_weapon_hardpoints.size()
		index += 1

	emit_signal("energy_weapon_changed")


func _cycle_missile_weapon(direction: int):
	missile_weapon_index = (missile_weapon_index + direction) % missile_weapon_hardpoints.size()

	# Skip any weapon slot that has no weapon loaded
	var index: int = 0
	while not missile_weapon_hardpoints[missile_weapon_index].is_weapon_loaded and index < missile_weapon_hardpoints.size():
		missile_weapon_index = (missile_weapon_index + direction) % missile_weapon_hardpoints.size()
		index += 1

	emit_signal("missile_weapon_changed")


func _destroy():
	var explosion = EXPLOSION_PREFAB.instance()
	explosion.transform.origin = transform.origin
	mission_controller.add_child(explosion)
	._destroy()


func _fire_energy_weapon():
	var weapon_cost = energy_weapon_hardpoints[energy_weapon_index].weapon_data.get("cost", 1.0)
	if energy_weapon_hardpoints[energy_weapon_index].countdown == 0 and weapon_battery >= weapon_cost:
		energy_weapon_hardpoints[energy_weapon_index].fire_weapon(self)
		weapon_battery -= weapon_cost

		return true

	return false


func _fire_missile_weapon(target = null):
	if missile_weapon_hardpoints[missile_weapon_index].countdown == 0 and missile_weapon_hardpoints[missile_weapon_index].ammo_count > 0:
		missile_weapon_hardpoints[missile_weapon_index].fire_missile_weapon(self, target)
		# TODO: subtract from missile weapon ammo

		return true

	return false


# Ranges from 0.75 to 1.25
func _get_engine_factor():
	return 0.75 + 0.5 * (power_distribution[ENGINE] / MAX_SYSTEM_POWER)


func _increment_power_level(system: int, direction: int):
	if system >= 0 and system < TOTAL_POWER_LEVELS:
		var previous_level: float = power_distribution[system]
		power_distribution[system] = clamp(previous_level + direction * POWER_INCREMENT, 0, MAX_SYSTEM_POWER)

		var power_diff: float = abs(previous_level - power_distribution[system])
		if power_diff != 0:
			# Redistribute power to other systems
			var increment = power_diff / 2
			var other_system: int = (system + 1) % TOTAL_POWER_LEVELS
			var steps: int = 0

			while power_diff != 0:
				previous_level = power_distribution[other_system]
				power_distribution[other_system] = clamp(previous_level - direction * min(increment, power_diff), 0, MAX_SYSTEM_POWER)
				power_diff -= abs(power_distribution[other_system] - previous_level)

				other_system = (other_system + 1) % TOTAL_POWER_LEVELS
				if other_system == system:
					other_system = (other_system + 1) % TOTAL_POWER_LEVELS

				steps += 1
				if steps > 10:
					print("Too many steps!")
					return

			# Update shields' recovery rate
			for quadrant in shields:
				quadrant.set_recovery_rate(power_distribution[SHIELD] / MAX_SYSTEM_POWER)


func _physics_process(delta):
	if warping == NONE:
		add_torque(turn_speed * torque_vector)
		apply_central_impulse(throttle * propulsion_force * _get_engine_factor() * -transform.basis.z)


func _process(delta):
	match warping:
		NONE:
			if weapon_battery < MAX_WEAPON_BATTERY:
				# Ranges from half recovery rate to full recovery rate (0.5 - 1.0)
				var battery_recovery_rate: float = WEAPON_BATTERY_RECOVERY_RATE * (0.5 + 0.5 * power_distribution[WEAPON] / MAX_SYSTEM_POWER)
				weapon_battery = min(MAX_WEAPON_BATTERY, weapon_battery + delta * battery_recovery_rate)


# PUBLIC


func get_energy_weapon_range():
	return energy_weapon_hardpoints[energy_weapon_index].weapon_data("firing_range", 10)


func get_max_speed():
	return max_speed * _get_engine_factor()


func get_overhead_icon():
	if source_folder != null:
		return load(source_folder + "/overhead.png")

	return null


func get_source_filename():
	return get_meta("source_file")


func get_targeting_endpoint():
	if is_a_target_in_range():
		return target_raycast.get_collision_point()

	return cockpit_view.global_transform.origin - 20 * transform.basis.z


func get_weapon_battery_percent():
	return weapon_battery / MAX_WEAPON_BATTERY


func hide_and_disable():
	for quadrant in shields:
		quadrant.set_monitorable(false)
		quadrant.set_monitoring(false)

	.hide_and_disable()


func is_a_target_in_range():
	return target_raycast.get_collider() is ActorBase


func set_weapon_hardpoints(energy_weapons: Array, missile_weapons: Array):
	for index in range(energy_weapons.size()):
		if index < energy_weapon_hardpoints.size():
			energy_weapon_hardpoints[index].set_weapon(energy_weapons[index])
		else:
		 break

	for index in range(missile_weapons.size()):
		if index < missile_weapon_hardpoints.size():
			missile_weapon_hardpoints[index].set_weapon(missile_weapons[index], get_meta("missile_capacity"))
		else:
		 break


func show_and_enable():
	for quadrant in shields:
		quadrant.set_monitorable(true)
		quadrant.set_monitoring(true)

	.show_and_enable()


signal energy_weapon_changed
signal missile_weapon_changed

const ShieldQuadrant = preload("ShieldQuadrant.gd")

const EXPLOSION_PREFAB = preload("res://prefabs/ship_explosion.tscn")
const MAX_SYSTEM_POWER: float = 60.0
const MAX_WEAPON_BATTERY: float = 100.0
const POWER_INCREMENT: int = 10
const TOTAL_SYSTEM_POWER: float = 90.0
const WEAPON_BATTERY_RECOVERY_RATE: float = 1.0
