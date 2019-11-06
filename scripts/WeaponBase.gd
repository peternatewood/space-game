extends RigidBody

var damage_hull: int = 15
var damage_shield: int = 10
var fire_delay: float = 0.3 # In seconds
var firing_force: float = 1.0
var firing_range: float = 10.0
var life: float = 5.0 # In seconds
var owner_ship
var speed: float = 80.0
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


func _process(delta):
	life -= delta
	if life <= 0:
		queue_free()


# PUBLIC


func destroy():
	queue_free()


static func get_damage_strength(damage: float):
	if damage < 15:
		return "Low"
	if damage < 25:
		return "Moderate"
	if damage < 35:
		return "High"

	return "Very High"
