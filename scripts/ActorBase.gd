extends RigidBody

var hitpoints: int = 100


func _ready():
	self.connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body):
	if body is EnergyBolt:
		hitpoints -= 10
		body.destroy()
	else:
		hitpoints -= 1


const EnergyBolt = preload("EnergyBolt.gd")
