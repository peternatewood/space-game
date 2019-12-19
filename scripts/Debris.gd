extends RigidBody

var hitpoints: int = 25


func _destroy():
	queue_free()


# PUBLIC


func deal_damage(amount: float):
	hitpoints -= amount
	if hitpoints <= 0:
		_destroy()
