extends Area

enum Category { COMMUNICATIONS, ENGINES, NAVIGATION, SENSORS, WEAPONS}

export (float) var hitpoints = -1

onready var max_hitpoints = get_meta("hitpoints")
onready var mission_controller = get_node_or_null("/root/Mission Controller")

var operative: bool = true
var owner_ship


func _ready():
	if mission_controller != null:
		mission_controller.connect("mission_ready", self, "_on_mission_ready")

	set_process(false)


func _deal_damage(amount: int):
	hitpoints -= amount
	emit_signal("damaged", get_hitpoints_percent())

	if hitpoints <= 0:
		_destroy()


# TODO: Allow a destroyed system to be repaired or no?
func _destroy():
	emit_signal("destroyed")
	operative = false


func _on_body_entered(body):
	if operative and body != owner_ship:
		if body is WeaponBase:
			_deal_damage(body.damage_hull)
			body.destroy()
		else:
			_deal_damage(1)


func _on_mission_ready():
	if hitpoints < 0:
		hitpoints = max_hitpoints

	self.connect("body_entered", self, "_on_body_entered")

	set_process(true)


# PUBLIC


func get_hitpoints_percent():
	return max(0, hitpoints / max_hitpoints)


signal damaged
signal destroyed

const WeaponBase = preload("WeaponBase.gd")

# TODO: Ignore collisions with parent