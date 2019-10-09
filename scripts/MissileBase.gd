extends "res://scripts/WeaponBase.gd"

var acceleration: float
var has_target: bool = false
var max_speed: float
var target
var turn_speed: float


func _ready():
	acceleration = get_meta("acceleration")
	damage_hull = get_meta("damage_hull")
	damage_shield = get_meta("damage_shield")
	fire_delay = get_meta("fire_delay")
	life = get_meta("life")
	max_speed = get_meta("max_speed")
	turn_speed = get_meta("turn_speed")
	weapon_name = get_meta("weapon_name")

	speed = 0.0


func _on_target_destroyed():
	has_target = false
	target = null


# PUBLIC


func add_speed(amount: float):
	speed += amount


func set_target(node):
	has_target = true
	target = node
	target.connect("destroyed", self, "_on_target_destroyed")
