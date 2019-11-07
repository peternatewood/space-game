extends "res://scripts/ShipBase.gd"

var beam_weapon_turrets: Array = []
var energy_weapon_turrets: Array = []
var missile_weapon_turrets: Array = []


func _ready():
	if get_meta("has_beam_weapon_turrets"):
		beam_weapon_turrets = get_node("Beam Weapon Turrets").get_children()
	if get_meta("has_energy_weapon_turrets"):
		energy_weapon_turrets = get_node("Energy Weapon Turrets").get_children()
	if get_meta("has_missile_weapon_turrets"):
		missile_weapon_turrets = get_node("Missile Weapon Turrets").get_children()

	for turret in beam_weapon_turrets:
		turret.hull_hitpoints = turret.max_hull_hitpoints

	for turret in energy_weapon_turrets:
		turret.hull_hitpoints = turret.max_hull_hitpoints

	for turret in missile_weapon_turrets:
		turret.hull_hitpoints = turret.max_hull_hitpoints


func _destroy():
	var explosion = EXPLOSION_PREFAB.instance()
	explosion.transform.origin = transform.origin
	mission_controller.add_child(explosion)
	._destroy()


func _on_mission_ready():
	for turret in energy_weapon_turrets:
		turret._on_mission_ready()

	._on_mission_ready()


# PUBLIC


func set_weapon_turrets(beam_weapons: Array = [], energy_weapons: Array = [], missile_weapons: Array = []):
	if beam_weapons.size() == beam_weapon_turrets.size():
		for index in range(beam_weapons.size()):
			beam_weapon_turrets[index].set_weapon(beam_weapons[index])

	if energy_weapons.size() == energy_weapon_turrets.size():
		for index in range(energy_weapons.size()):
			energy_weapon_turrets[index].set_weapon(energy_weapons[index])

	if missile_weapons.size() == missile_weapon_turrets.size():
		for index in range(missile_weapons.size()):
			missile_weapon_turrets[index].set_weapon(missile_weapons[index])


const EXPLOSION_PREFAB = preload("res://prefabs/capital_ship_explosion.tscn")
