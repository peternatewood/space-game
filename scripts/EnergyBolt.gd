extends "res://scripts/WeaponBase.gd"


func _ready():
	damage_hull = 15
	damage_shield = 10
	fire_delay = 0.4
	weapon_name = "Energy Bolt"


# PUBLIC


func add_speed(amount: float):
	speed += amount
	add_central_force(speed * -transform.basis.z)


const COST: float = 1.0
const RANGE: float = 33.333333
