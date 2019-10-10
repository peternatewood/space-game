extends "res://scripts/WeaponBase.gd"


func _ready():
	damage_hull = get_meta("damage_hull")
	damage_shield = get_meta("damage_shield")
	fire_delay = get_meta("fire_delay")
	firing_force = get_meta("firing_force")
	life = get_meta("life")
	weapon_name = get_meta("weapon_name")


# PUBLIC


func add_speed(amount: float):
	firing_force += amount
	add_central_force(firing_force * -transform.basis.z)


const COST: float = 1.0
