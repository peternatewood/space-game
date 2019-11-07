extends "res://scripts/EnergyWeaponBase.gd"

onready var audio_player = get_node_or_null("Audio Player")

var has_audio_player: bool = false


func _ready():
	firing_force = get_meta("firing_force")
	has_audio_player = audio_player != null


# PUBLIC


func add_speed(amount: float):
	if has_audio_player:
		audio_player.play()

	firing_force += amount
	add_central_force(firing_force * -transform.basis.z)
