extends Area

onready var mission_controller = get_node("/root/Mission Controller")

var damage_hull: float = 15
var damage_shield: float = 10
var fire_delay: float = 0.3 # In seconds
var firing_force: float = 1.0
var firing_range: float = 10.0
var life: float = 5.0 # In seconds
var owner_ship
var speed: float = 15.0
var weapon_name: String = "weapon"


func _ready():
	if has_meta("damage_hull"):
		damage_hull = get_meta("damage_hull")
	if has_meta("damage_shield"):
		damage_shield = get_meta("damage_shield")
	if has_meta("fire_delay"):
		fire_delay = get_meta("fire_delay")
	if has_meta("life"):
		life = get_meta("life")
	if has_meta("weapon_name"):
		weapon_name = get_meta("weapon_name")
	if has_meta("firing_range"):
		firing_range = get_meta("firing_range")
	if has_meta("speed"):
		speed = get_meta("speed")

	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body):
	if body != owner_ship:
		if body is ShipBase or body is TurretBase or body is Debris:
			body.deal_damage(damage_hull)
			destroy()


func _process(delta):
	life -= delta
	if life <= 0:
		queue_free()

	translate(delta * speed * Vector3.FORWARD)


# PUBLIC


func destroy():
	var impact = IMPACT_PREFAB.instance()
	mission_controller.add_child(impact)
	impact.transform = global_transform

	queue_free()


static func get_ammo_cost_description(cost: float):
	if cost < 2:
		return "Low"
	if cost < 8:
		return "Moderate"
	if cost < 15:
		return "High"

	return "Very High"


static func get_battery_cost_description(cost: float):
	if cost < 2:
		return "Low"
	if cost < 4:
		return "Moderate"
	if cost < 6:
		return "High"

	return "Very High"


static func get_damage_strength(damage: float):
	if damage < 15:
		return "Low"
	if damage < 25:
		return "Moderate"
	if damage < 35:
		return "High"

	return "Very High"


const Debris = preload("Debris.gd")
const ShipBase = preload("ShipBase.gd")
const TurretBase = preload("TurretBase.gd")

const IMPACT_PREFAB = preload("res://prefabs/weapon_impact.tscn")
