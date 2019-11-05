extends "res://scripts/ActorBase.gd"

var fire_countdown: float = 0
var is_weapon_loaded: bool = false
var weapon


func _process(delta):
	if fire_countdown > 0:
		fire_countdown -= delta


# PUBLIC


func set_weapon(weapon_scene):
	if weapon_scene != null:
		is_weapon_loaded = true
		weapon = weapon_scene
