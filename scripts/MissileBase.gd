extends "res://scripts/WeaponBase.gd"

var acceleration: float
var has_target: bool = false
var max_speed: float
var search_radius: float
var target
var turn_speed: float


func _ready():
	if has_meta("acceleration"):
		acceleration = get_meta("acceleration")
	if has_meta("max_speed"):
		max_speed = get_meta("max_speed")
	if has_meta("search_radius"):
		search_radius = get_meta("search_radius")
	if has_meta("turn_speed"):
		turn_speed = get_meta("turn_speed")

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
