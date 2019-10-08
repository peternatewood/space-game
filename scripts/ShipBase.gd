extends "res://scripts/ActorBase.gd"

export (String) var faction

onready var energy_weapon_hardpoints = get_node("Energy Weapon Hardpoints 1").get_children()
onready var max_speed: float = get_meta("max_speed")
onready var missile_weapon_hardpoints = get_node("Missile Weapon Hardpoints").get_children()
onready var shield_front = get_node("Shield Front")
onready var shield_left = get_node("Shield Left")
onready var shield_rear = get_node("Shield Rear")
onready var shield_right = get_node("Shield Right")
onready var ship_class: String = get_meta("ship_class")
onready var source_folder = get_meta("source_folder")

var current_target
var energy_weapon_countdown: float = 0.0
var energy_weapon_index: int = 0
var has_target: bool = false
# TODO: figure out how to accurately calculate this
var missile_weapon_countdown: float = 0.0
var missile_weapon_index: int = 0
var power_distribution: Array = [
	float(TOTAL_SYSTEM_POWER / 3),
	float(TOTAL_SYSTEM_POWER / 3),
	float(TOTAL_SYSTEM_POWER / 3)
]
var target_index: int = 0
var throttle: float
var torque_vector: Vector3
var weapon_battery: float = MAX_WEAPON_BATTERY


func _ready():
	max_hull_hitpoints = get_meta("hull_hitpoints")
	max_speed = MASS_TO_MAX_SPEED_FACTOR * mass

	var shield_hitpoints = get_meta("shield_hitpoints")
	shield_front.set_max_hitpoints(shield_hitpoints)
	shield_left.set_max_hitpoints(shield_hitpoints)
	shield_rear.set_max_hitpoints(shield_hitpoints)
	shield_right.set_max_hitpoints(shield_hitpoints)
	shield_front.set_recovery_rate(power_distribution[SHIELD] / MAX_SYSTEM_POWER)
	shield_left.set_recovery_rate(power_distribution[SHIELD] / MAX_SYSTEM_POWER)
	shield_rear.set_recovery_rate(power_distribution[SHIELD] / MAX_SYSTEM_POWER)
	shield_right.set_recovery_rate(power_distribution[SHIELD] / MAX_SYSTEM_POWER)


func _fire_energy_weapon():
	if energy_weapon_countdown == 0 and weapon_battery >= EnergyBolt.COST:
		# Instance bolt and set its layer and mask so it doesn't immediately collide with the ship firing it
		var bolt = ENERGY_BOLT.instance()
		bolt.add_collision_exception_with(self)
		bolt.owner_ship = self

		get_tree().get_root().add_child(bolt)
		bolt.transform.origin = energy_weapon_hardpoints[energy_weapon_index].global_transform.origin
		bolt.look_at(bolt.transform.origin - transform.basis.z, transform.basis.y)
		bolt.add_speed(get_linear_velocity().length())

		energy_weapon_countdown = bolt.fire_delay
		energy_weapon_index = (energy_weapon_index + 1) % energy_weapon_hardpoints.size()

		weapon_battery -= EnergyBolt.COST

		return true

	return false


func _fire_missile_weapon(target = null):
	if missile_weapon_countdown == 0:
		var missile = MISSILE.instance()
		missile.add_collision_exception_with(self)
		missile.owner_ship = self

		get_tree().get_root().add_child(missile)
		missile.transform.origin = missile_weapon_hardpoints[missile_weapon_index].global_transform.origin
		missile.look_at(missile.transform.origin - transform.basis.z, transform.basis.y)
		missile.add_speed(get_linear_velocity().length())
		if target != null:
			missile.set_target(target)

		missile_weapon_countdown = missile.fire_delay
		missile_weapon_index = (missile_weapon_index + 1) % missile_weapon_hardpoints.size()

		return true

	return false


func _get_energy_weapon_range():
	# TODO: update this for more general use after adding more energy weapons
	return EnergyBolt.RANGE


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
			shield_front.set_recovery_rate(power_distribution[SHIELD] / MAX_SYSTEM_POWER)
			shield_left.set_recovery_rate(power_distribution[SHIELD] / MAX_SYSTEM_POWER)
			shield_rear.set_recovery_rate(power_distribution[SHIELD] / MAX_SYSTEM_POWER)
			shield_right.set_recovery_rate(power_distribution[SHIELD] / MAX_SYSTEM_POWER)


func _on_target_destroyed():
	has_target = false
	current_target = null
	target_index = 0


func _physics_process(delta):
	add_torque(TURN_SPEED * torque_vector)
	apply_central_impulse(throttle * _get_engine_factor() * -transform.basis.z)


func _process(delta):
	if energy_weapon_countdown != 0:
		energy_weapon_countdown = max(0, energy_weapon_countdown - delta)

	if missile_weapon_countdown != 0:
		missile_weapon_countdown = max(0, missile_weapon_countdown - delta)

	if weapon_battery < MAX_WEAPON_BATTERY:
		# Ranges from half recovery rate to full recovery rate (0.5 - 1.0)
		var battery_recovery_rate: float = WEAPON_BATTERY_RECOVERY_RATE * (0.5 + 0.5 * power_distribution[WEAPON] / MAX_SYSTEM_POWER)
		weapon_battery = min(MAX_WEAPON_BATTERY, weapon_battery + delta * battery_recovery_rate)


func _set_current_target(node):
	if has_target:
		current_target.disconnect("destroyed", self, "_on_target_destroyed")

	has_target = true
	current_target = node
	current_target.connect("destroyed", self, "_on_target_destroyed")


func _start_destruction():
	var smoke = DESTRUCTION_SMOKE.instance()
	add_child(smoke)

	._start_destruction()


# Loops through the given array of possible targets; if one is found, set it as the current target and return true, otherwise do nothing and return false
func _target_next_of_alignment(possible_targets: Array, alignment: int):
	var targets_count = possible_targets.size()
	var steps: int = 0
	if has_target:
		target_index = (target_index + 1) % targets_count
		steps += 1

	# Ensures we loop through all targets just once
	while steps < targets_count:
		var target = possible_targets[target_index]
		if mission_controller.get_alignment(faction, target.faction) == alignment:
			_set_current_target(target)
			return true

		target_index = (target_index + 1) % targets_count
		steps += 1

	return false


# PUBLIC


func get_overhead_icon():
	if source_folder != null:
		return load(source_folder + "/overhead.png")

	return null


func get_max_speed():
	return max_speed * _get_engine_factor()


func get_source_filename():
	return get_meta("source_file")


func get_weapon_battery_percent():
	return weapon_battery / MAX_WEAPON_BATTERY


enum { WEAPON, SHIELD, ENGINE, TOTAL_POWER_LEVELS }

const EnergyBolt = preload("EnergyBolt.gd")

const ACCELERATION: float = 0.1
const DESTRUCTION_SMOKE = preload("res://models/Destruction_Smoke.tscn")
const ENERGY_BOLT = preload("res://models/Energy_Bolt.tscn")
const MISSILE = preload("res://models/missile/missile.dae")
const MASS_TO_MAX_SPEED_FACTOR: float = 32.129448
const MAX_SYSTEM_POWER: float = 60.0
const MAX_THROTTLE: float = 1.0
const MAX_WEAPON_BATTERY: float = 100.0
const POWER_INCREMENT: int = 10
const TOTAL_SYSTEM_POWER: float = 120.0
const TURN_SPEED: float = 2.5
const WEAPON_BATTERY_RECOVERY_RATE: float = 1.0

"""
TODO: figure out the curve for this conversion; for now we're just expecting 0.85 damping for all ships
Damping: 0.25 | Mass: 1.0 | Max Speed: 209.063675

Damping: 0.50 | Mass: 0.5 | Max Speed: 124.124451
Damping: 0.50 | Mass: 1.0 | Max Speed:  87.062263
Damping: 0.50 | Mass: 2.0 | Max Speed:  43.531090
Damping: 0.50 | Mass:10.0 | Max Speed:   8.706212

Damping: 0.85 | Mass: 0.5 | Max Speed:  64.258858
Damping: 0.85 | Mass: 1.0 | Max Speed:  32.129448
Damping: 0.85 | Mass: 2.0 | Max Speed:  16.064760
Damping: 0.85 | Mass:10.0 | Max Speed:   3.212944

Damping: 0.95 | Mass: 1.0 | Max Speed:  20.532631
"""
