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
		if body is EnergyBolt:
			_damage(body.DAMAGE_SHIELD)
			body.destroy()


func _process(delta):
	if flicker_countdown != 0:
		flicker_countdown -= delta

		var shield_material = mesh.get_surface_material(0)
		var albedo_color = shield_material.albedo_color

		albedo_color.a = flicker_countdown / FLICKER_DELAY
		shield_material.set_albedo(albedo_color)

		if flicker_countdown <= 0:
			mesh.hide()
			flicker_countdown = 0


signal shield_hit

const EnergyBolt = preload("EnergyBolt.gd")

const FLICKER_DELAY: float = 0.125
