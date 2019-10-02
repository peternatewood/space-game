extends Area

onready var mesh: MeshInstance = get_node("mesh")

var flicker_countdown: float
var hitpoints: int = 40


func _ready():
	self.connect("body_entered", self, "_on_body_entered")


func _damage(amount: int):
	hitpoints = max(0, hitpoints - amount)
	flicker_countdown = FLICKER_DELAY
	mesh.show()


func _on_body_entered(body):
	# Only handle collisions if this shield quadrant is still up
	if hitpoints > 0:
		if body is WeaponBase:
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


signal shield_hit

const WeaponBase = preload("WeaponBase.gd")

const FLICKER_DELAY: float = 0.45
