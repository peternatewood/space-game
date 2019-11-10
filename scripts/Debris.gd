extends RigidBody

var hitpoints: int = 25


func _ready():
	self.connect("body_entered", self, "_on_body_entered")


func _deal_damage(amount: int):
	hitpoints -= amount
	if hitpoints <= 0:
		_destroy()


func _destroy():
	queue_free()


func _on_body_entered(body):
	if body is WeaponBase:
		_deal_damage(body.damage_hull)
		body.destroy()
	else:
		_deal_damage(1)


const WeaponBase = preload("WeaponBase.gd")
