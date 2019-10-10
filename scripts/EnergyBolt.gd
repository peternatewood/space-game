extends "res://scripts/WeaponBase.gd"


func _ready():
	damage_hull = get_meta("damage_hull")
	damage_shield = get_meta("damage_shield")
	fire_delay = get_meta("fire_delay")
	life = get_meta("life")
	speed = get_meta("speed")
	weapon_name = get_meta("weapon_name")


# PUBLIC


func add_speed(amount: float):
	speed += amount
	add_central_force(speed * -transform.basis.z)


const COST: float = 1.0
const RANGE: float = 33.333333
