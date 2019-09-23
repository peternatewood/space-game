extends RigidBody

var hitpoints: int = 100


func _ready():
	self.connect("body_entered", self, "_on_body_entered")


func _deal_damage(amount: int):
	hitpoints -= amount
	if hitpoints <= 0:
		queue_free()


func _on_body_entered(body):
	if body is EnergyBolt:
		_deal_damage(10)
		body.destroy()
	else:
		_deal_damage(1)


const EnergyBolt = preload("EnergyBolt.gd")
