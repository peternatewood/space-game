extends "res://scripts/ActorBase.gd"

onready var energy_weapon_hardpoints = get_node("Energy Weapon Hardpoints 1").get_children()
onready var shield_front = get_node("Shield Front")
onready var shield_left = get_node("Shield Left")
onready var shield_rear = get_node("Shield Rear")
onready var shield_right = get_node("Shield Right")

var energy_weapon_countdown: float = 0.0
var energy_weapon_index: int = 0
var throttle: float
var torque_vector: Vector3


func _ready():
	# Set the shield collision layers and masks to be the same as that of the ship
	shield_front.set_collision_layer(collision_layer)
	shield_front.set_collision_mask(collision_mask)
	shield_left.set_collision_layer(collision_layer)
	shield_left.set_collision_mask(collision_mask)
	shield_rear.set_collision_layer(collision_layer)
	shield_rear.set_collision_mask(collision_mask)
	shield_right.set_collision_layer(collision_layer)
	shield_right.set_collision_mask(collision_mask)


func _fire_energy_weapon():
	# Instance bolt and set its layer and mask so it doesn't immediately collide with the ship firing it
	var bolt = ENERGY_BOLT.instance()
	bolt.set_collision_layer(collision_layer)
	bolt.set_collision_mask(collision_mask)

	get_tree().get_root().add_child(bolt)
	bolt.transform.origin = energy_weapon_hardpoints[energy_weapon_index].global_transform.origin
	bolt.look_at(bolt.transform.origin - transform.basis.z, transform.basis.y)
	bolt.add_speed(get_linear_velocity().length())

	energy_weapon_countdown = ENERGY_WEAPON_DELAY
	energy_weapon_index = (energy_weapon_index + 1) % energy_weapon_hardpoints.size()


func _physics_process(delta):
	add_torque(TURN_SPEED * torque_vector)
	apply_central_impulse(throttle * -transform.basis.z)


func _process(delta):
	if energy_weapon_countdown != 0:
		energy_weapon_countdown = max(0, energy_weapon_countdown - delta)


const ACCELERATION: float = 0.1
const ENERGY_BOLT = preload("res://models/Energy_Bolt.tscn")
const ENERGY_WEAPON_DELAY: float = 0.1
const MAX_THROTTLE: float = 1.0
const TURN_SPEED: float = 2.5
