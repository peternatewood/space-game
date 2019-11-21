extends "res://scripts/ShipBase.gd"

export (Array, int) var initial_orders = [ 0, 0, 0, 0, 0, 0 ]

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

	_disable_shapes(true)

	# Generate debris
	if has_node("Debris"):
		for node in get_node("Debris").get_children():
			var debris = DEBRIS_PREFAB.instance()

			var debris_mesh = node.get_node("Mesh").duplicate(DUPLICATE_USE_INSTANCING)
			debris.add_child(debris_mesh)
			debris_mesh.transform = Transform.IDENTITY
			var debris_collider = node.get_node("Collision Shape").duplicate(DUPLICATE_USE_INSTANCING)
			debris.add_child(debris_collider)
			debris_collider.transform = Transform.IDENTITY
			debris_collider.set_disabled(false)

			debris.set_mass(mass)
			mission_controller.add_child(debris)
			debris.transform = node.global_transform

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


const DEBRIS_PREFAB = preload("res://prefabs/ship_debris.tscn")
const EXPLOSION_PREFAB = preload("res://prefabs/capital_ship_explosion.tscn")
