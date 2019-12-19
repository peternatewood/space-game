extends Area

enum Category { COMMUNICATIONS, ENGINES, NAVIGATION, SENSORS, WEAPONS }

export (float) var hitpoints = -1

onready var max_hitpoints = get_meta("hitpoints")
onready var mission_controller = get_node_or_null("/root/Mission Controller")

var category: int
var collision_shape: CollisionShape
var operative: bool = true
var owner_ship


func _ready():
	if mission_controller != null:
		mission_controller.connect("mission_ready", self, "_on_mission_ready")

	for child in get_children():
		if child is CollisionShape:
			collision_shape = child
			break

	match name:
		"Communications":
			category = Category.COMMUNICATIONS
		"Engines":
			category = Category.ENGINES
		"Navigation":
			category = Category.NAVIGATION
		"Sensors":
			category = Category.SENSORS
		"Weapons":
			category = Category.WEAPONS

	set_process(false)


func _deal_damage(amount: float):
	hitpoints -= amount
	emit_signal("damaged", category, get_hitpoints_percent())

	if hitpoints <= 0:
		_destroy()


# TODO: Allow a destroyed system to be repaired or no?
func _destroy():
	emit_signal("destroyed", category)
	operative = false


func _on_area_entered(area):
	if operative:
		if area is WeaponBase:
			_deal_damage(area.damage_hull)
			area.destroy()


func _on_mission_ready():
	if hitpoints < 0:
		hitpoints = max_hitpoints

	self.connect("area_entered", self, "_on_area_entered")

	set_process(true)


# PUBLIC


func get_hitpoints_percent():
	return max(0, hitpoints / max_hitpoints)


func get_points_global():
	var points: PoolVector3Array = []

	for point in collision_shape.shape.points:
		points.append(collision_shape.global_transform.xform(point))

	return points


signal damaged
signal destroyed

const WeaponBase = preload("WeaponBase.gd")
