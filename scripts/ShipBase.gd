extends "res://scripts/ActorBase.gd"

onready var directory = get_meta("directory")
onready var energy_weapon_hardpoints = get_node("Energy Weapon Hardpoints 1").get_children()
onready var missile_weapon_hardpoints = get_node("Missile Weapon Hardpoints").get_children()
onready var shield_front = get_node("Shield Front")
onready var shield_left = get_node("Shield Left")
onready var shield_rear = get_node("Shield Rear")
onready var shield_right = get_node("Shield Right")

var energy_weapon_countdown: float = 0.0
var energy_weapon_index: int = 0
var missile_weapon_countdown: float = 0.0
var missile_weapon_index: int = 0
var throttle: float
var torque_vector: Vector3


func _fire_energy_weapon():
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


func _fire_missile_weapon(target = null):
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


func _physics_process(delta):
	add_torque(TURN_SPEED * torque_vector)
	apply_central_impulse(throttle * -transform.basis.z)


func _process(delta):
	if energy_weapon_countdown != 0:
		energy_weapon_countdown = max(0, energy_weapon_countdown - delta)

	if missile_weapon_countdown != 0:
		missile_weapon_countdown = max(0, missile_weapon_countdown - delta)


# PUBLIC


func get_overhead_icon():
	if directory != null:
		return load(directory + "/overhead.png")

	return null


const ACCELERATION: float = 0.1
const ENERGY_BOLT = preload("res://models/Energy_Bolt.tscn")
const MISSILE = preload("res://models/missile/missile.dae")
const MAX_THROTTLE: float = 1.0
const TURN_SPEED: float = 2.5
