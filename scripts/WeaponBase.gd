extends Area

onready var damage_hull: float = get_meta("damage_hull")
onready var damage_shield: float = get_meta("damage_shield")
onready var damage_subsystem: float = get_meta("damage_subsystem")
onready var fire_delay: float = get_meta("fire_delay")
onready var firing_range: float = get_meta("firing_range")
onready var life: float = get_meta("life")
onready var mission_controller = get_node("/root/Mission Controller")
onready var speed: float = get_meta("speed")
onready var weapon_name: float = get_meta("weapon_name")

var owner_ship


func _ready():
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body):
	if body != owner_ship:
		if body is ShipBase or body is Debris or (body is TurretBase and body.capital_ship != owner_ship):
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
