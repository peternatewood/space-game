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
		turret.add_collision_exception_with(self)
		turret.hull_hitpoints = turret.max_hull_hitpoints
		add_collision_exception_with(turret)

	for turret in energy_weapon_turrets:
		turret.add_collision_exception_with(self)
		turret.hull_hitpoints = turret.max_hull_hitpoints
		add_collision_exception_with(turret)

	for turret in missile_weapon_turrets:
		turret.add_collision_exception_with(self)
		turret.hull_hitpoints = turret.max_hull_hitpoints
		add_collision_exception_with(turret)


func _on_mission_ready():
	for turret in energy_weapon_turrets:
		turret._on_mission_ready()

	._on_mission_ready()
