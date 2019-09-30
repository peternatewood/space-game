extends RigidBody

export (int) var hitpoints


func _ready():
	self.connect("body_entered", self, "_on_body_entered")


func _deal_damage(amount: int):
	hitpoints -= amount
	if hitpoints <= 0:
		_destroy()


func _destroy():
	emit_signal("destroyed")
	queue_free()


func _on_body_entered(body):
	if body is EnergyBolt or body is Missile:
		_deal_damage(body.DAMAGE_HULL)
		body.destroy()
	else:
		_deal_damage(1)


signal destroyed

const EnergyBolt = preload("EnergyBolt.gd")
const Missile = preload("Missile.gd")
