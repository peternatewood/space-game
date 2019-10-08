extends Area

onready var mesh: MeshInstance = get_node("mesh")

var flicker_countdown: float = 0.0
var hitpoints: float
var max_hitpoints: float = 100.0
var recovery_countdown: float = 0.0
var recovery_rate: float # Hitpoints per second


func _ready():
	hitpoints = max_hitpoints
	self.connect("body_entered", self, "_on_body_entered")


func _damage(amount: int):
	hitpoints = max(0, hitpoints - amount)
	flicker_countdown = FLICKER_DELAY
	mesh.show()
	emit_signal("hitpoints_changed", hitpoints / max_hitpoints)


func _on_body_entered(body):
	# Only handle collisions if this shield quadrant is still up
	if hitpoints > 0:
		if body is WeaponBase and body.owner_ship != get_parent():
			_damage(body.damage_shield)
			body.destroy()


func _process(delta):
	if flicker_countdown != 0:
		flicker_countdown -= delta

		var albedo_color = mesh.get_surface_material(0).albedo_color

		albedo_color.a = flicker_countdown / FLICKER_DELAY
		mesh.get_surface_material(0).set_albedo(albedo_color)

		if flicker_countdown <= 0:
			mesh.hide()
			flicker_countdown = 0
			recovery_countdown = RECOVERY_DELAY
	elif recovery_countdown != 0:
		recovery_countdown -= delta

		if recovery_countdown <= 0:
			recovery_countdown = 0
	elif hitpoints < max_hitpoints:
		hitpoints += delta * recovery_rate
		emit_signal("hitpoints_changed", hitpoints / max_hitpoints)

		if hitpoints > max_hitpoints:
			hitpoints = max_hitpoints


# PUBLIC


func set_max_hitpoints(amount: float):
	max_hitpoints = amount
	hitpoints = amount


func set_recovery_rate(system_power: float):
	recovery_rate = MIN_RECOVERY_RATE + system_power * (MAX_RECOVERY_RATE - MIN_RECOVERY_RATE)


signal hitpoints_changed

const WeaponBase = preload("WeaponBase.gd")

const FLICKER_DELAY: float = 0.45
const MAX_RECOVERY_RATE: float = 10.0
const MIN_RECOVERY_RATE: float = 2.0
const RECOVERY_DELAY: float = 0.85 # Starts after flicker delay
