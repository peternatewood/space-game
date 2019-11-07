extends "res://scripts/EnergyWeaponBase.gd"


func _ready():
	firing_force = get_meta("firing_force")


# PUBLIC


func add_speed(amount: float):
	firing_force += amount
	add_central_force(firing_force * -transform.basis.z)
