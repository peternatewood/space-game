extends Area

export (float) var damage_hull = 0.0
export (float) var damage_shield = 0.0
export (float) var damage_subsystem = 0.0
export (float) var fire_delay = 0.0
export (float) var firing_range = 0.0
export (float) var life = 0.0
export (float) var speed = 0.0
export (String) var weapon_name = "weapon"

onready var mission_controller = get_node("/root/Mission Controller")

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
