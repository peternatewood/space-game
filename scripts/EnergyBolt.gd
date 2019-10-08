extends "res://scripts/WeaponBase.gd"


func _ready():
	damage_hull = 15
	damage_shield = 10


# PUBLIC


func add_speed(amount: float):
	speed += amount
	add_central_force(speed * -transform.basis.z)


const COST: float = 1.0
const RANGE: float = 33.333333
