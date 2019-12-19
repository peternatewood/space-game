extends "res://scripts/WeaponBase.gd"

var cost: float = 1.0


func _ready():
	if has_meta("cost"):
		cost = get_meta("cost")


# PUBLIC


func add_speed(amount: float):
	speed += amount
