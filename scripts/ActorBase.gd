extends RigidBody

export (int) var hitpoints

onready var loader = get_node("/root/SceneLoader")


func _ready():
	self.connect("body_entered", self, "_on_body_entered")
	loader.connect("scene_loaded", self, "_on_scene_loaded")

	set_process(false)


func _deal_damage(amount: int):
	hitpoints -= amount
	emit_signal("damaged")
	if hitpoints <= 0:
		_destroy()


func _destroy():
	emit_signal("destroyed")
	queue_free()


func _on_body_entered(body):
	if body is WeaponBase:
		_deal_damage(body.damage_hull)
		body.destroy()
	else:
		_deal_damage(1)


func _on_scene_loaded():
	set_process(true)


signal damaged
signal destroyed

const WeaponBase = preload("WeaponBase.gd")
