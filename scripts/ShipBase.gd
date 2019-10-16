extends "res://scripts/ActorBase.gd"

enum { WEAPON, SHIELD, ENGINE, TOTAL_POWER_LEVELS }
enum { FRONT, REAR, LEFT, RIGHT, QUADRANT_COUNT }

export (String) var faction

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
onready var ship_class: String = get_meta("ship_class")
onready var source_folder = get_meta("source_folder")
onready var target_raycast = get_node("Target Raycast")

var current_target
var energy_weapon_index: int = 0
var has_target: bool = false
var max_speed: float
var missile_weapon_index: int = 0
var power_distribution: Array = [
	float(TOTAL_SYSTEM_POWER / 3),
	float(TOTAL_SYSTEM_POWER / 3),
	float(TOTAL_SYSTEM_POWER / 3)
]
var propulsion_force: float = 1.0
var target_index: int = 0
var targeting_ships: Array = []
var throttle: float
var torque_vector: Vector3
var turn_speed: float
var weapon_battery: float = MAX_WEAPON_BATTERY


func _ready():
	if has_meta("propulsion_force"):
		propulsion_force = get_meta("propulsion_force")
	if has_meta("max_hull_hitpoints"):
		max_hull_hitpoints = get_meta("hull_hitpoints")
	if has_meta("max_speed"):
		max_speed = get_meta("max_speed")

	# Set turn speed based on mass
	turn_speed = 2.5 * mass

	var shield_hitpoints = get_meta("shield_hitpoints")
	for quadrant in shields:
		quadrant.set_max_hitpoints(shield_hitpoints)
		quadrant.set_recovery_rate(power_distribution[SHIELD] / MAX_SYSTEM_POWER)

	# TODO: figure out how to assign weapons from the editor for npc ships, and from the loadout menu for the player and wingmates
	for energy_weapon in energy_weapon_hardpoints:
		energy_weapon.set_weapon(ENERGY_BOLT)

	for missile_weapon in missile_weapon_hardpoints:
		missile_weapon.set_weapon(MISSILE, get_meta("missile_capacity"))


func _cycle_energy_weapon(direction: int):
	energy_weapon_index = (energy_weapon_index + direction) % energy_weapon_hardpoints.size()
	emit_signal("energy_weapon_changed")


func _cycle_missile_weapon(direction: int):
	missile_weapon_index = (missile_weapon_index + direction) % missile_weapon_hardpoints.size()
	emit_signal("missile_weapon_changed")


func _fire_energy_weapon():
	var weapon_cost = energy_weapon_hardpoints[energy_weapon_index].get_weapon_data("cost")
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


func _get_throttle_to_match_target_speed():
	var target_speed: float = current_target.linear_velocity.length()
	# The target ship might be flying faster than this ship can
	return min(target_speed / get_max_speed(), 1)


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


func _on_target_destroyed():
	has_target = false
	current_target = null
	target_index = 0


func _on_targeting_ship_destroyed(destroyed_ship):
	var index: int = 0
	for ship in targeting_ships:
		if ship == destroyed_ship:
			targeting_ships.remove(index)
			return
		index += 1


func _physics_process(delta):
	add_torque(turn_speed * torque_vector)
	apply_central_impulse(throttle * propulsion_force * _get_engine_factor() * -transform.basis.z)


func _process(delta):
	if weapon_battery < MAX_WEAPON_BATTERY:
		# Ranges from half recovery rate to full recovery rate (0.5 - 1.0)
		var battery_recovery_rate: float = WEAPON_BATTERY_RECOVERY_RATE * (0.5 + 0.5 * power_distribution[WEAPON] / MAX_SYSTEM_POWER)
		weapon_battery = min(MAX_WEAPON_BATTERY, weapon_battery + delta * battery_recovery_rate)


func _set_current_target(node):
	if has_target:
		current_target.disconnect("destroyed", self, "_on_target_destroyed")

	if node.is_alive:
		has_target = true
		current_target = node
		current_target.connect("destroyed", self, "_on_target_destroyed")
		current_target.handle_being_targeted(self)


func _start_destruction():
	var smoke = DESTRUCTION_SMOKE.instance()
	add_child(smoke)

	._start_destruction()


# Loops through the given array of possible targets; if one is found, set it as the current target and return true, otherwise do nothing and return false
func _target_next_of_alignment(alignment: int):
	var possible_targets = mission_controller.get_targets()
	var targets_count = possible_targets.size()
	var steps: int = 0
	if has_target:
		target_index = (target_index + 1) % targets_count
		steps += 1

	# Ensures we loop through all targets just once
	while steps < targets_count:
		var target = possible_targets[target_index]
		if self != target and mission_controller.get_alignment(faction, target.faction) == alignment:
			_set_current_target(target)
			return true

		target_index = (target_index + 1) % targets_count
		steps += 1

	return false


# PUBLIC


func get_energy_weapon_range():
	return energy_weapon_hardpoints[energy_weapon_index].get_weapon_data("firing_range")


func get_overhead_icon():
	if source_folder != null:
		return load(source_folder + "/overhead.png")

	return null


func get_max_speed():
	return max_speed * _get_engine_factor()


func get_source_filename():
	return get_meta("source_file")


func get_targeting_endpoint():
	if is_a_target_in_range():
		return target_raycast.get_collision_point()

	return cockpit_view.global_transform.origin - 20 * transform.basis.z


func get_weapon_battery_percent():
	return weapon_battery / MAX_WEAPON_BATTERY


func handle_being_targeted(targeting_ship):
	targeting_ships.append(targeting_ship)
	targeting_ship.connect("destroyed", self, "_on_targeting_ship_destroyed", [ targeting_ship ])


func is_a_target_in_range():
	return target_raycast.get_collider() is ActorBase


signal energy_weapon_changed
signal missile_weapon_changed

const ActorBase = preload("ActorBase.gd")
const EnergyBolt = preload("EnergyBolt.gd")
const ShieldQuadrant = preload("ShieldQuadrant.gd")

const ACCELERATION: float = 0.1
const DESTRUCTION_SMOKE = preload("res://models/Destruction_Smoke.tscn")
const ENERGY_BOLT = preload("res://models/energy_bolt/energy_bolt.dae")
const MISSILE = preload("res://models/missile/missile.dae")
const MAX_SYSTEM_POWER: float = 60.0
const MAX_THROTTLE: float = 1.0
const MAX_WEAPON_BATTERY: float = 100.0
const POWER_INCREMENT: int = 10
const TOTAL_SYSTEM_POWER: float = 90.0
const WEAPON_BATTERY_RECOVERY_RATE: float = 1.0
