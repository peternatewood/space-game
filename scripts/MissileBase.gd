extends "res://scripts/WeaponBase.gd"

var acceleration: float = 20.0
var has_target: bool = false
var target
var max_speed: float = 100.0
var turn_speed: float = 1.5

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
