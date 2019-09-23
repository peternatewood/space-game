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
			_damage(10)
			body.destroy()


func _process(delta):
	if flicker_countdown != 0:
		flicker_countdown -= delta

		if flicker_countdown <= 0:
			mesh.hide()
			flicker_countdown = 0


signal shield_hit

const EnergyBolt = preload("EnergyBolt.gd")

const FLICKER_DELAY: float = 0.125
