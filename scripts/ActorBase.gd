extends RigidBody

export (int) var hitpoints

onready var loader = get_node("/root/SceneLoader")

var destruction_countdown: float
var destruction_delay: float = 0.0
var is_alive: bool = true


func _ready():
	self.connect("body_entered", self, "_on_body_entered")
	loader.connect("scene_loaded", self, "_on_scene_loaded")

	set_process(false)


func _deal_damage(amount: int):
	hitpoints -= amount
	emit_signal("damaged")
	if hitpoints <= 0:
		_start_destruction()


func _destroy():
	queue_free()


func _on_body_entered(body):
	if body is WeaponBase:
		_deal_damage(body.damage_hull)
		body.destroy()
	else:
		_deal_damage(1)


func _on_scene_loaded():
	set_process(true)


func _process(delta):
	if not is_alive:
		destruction_countdown -= delta
		if destruction_countdown <= 0:
			set_process(false)
			_destroy()


func _start_destruction():
	emit_signal("destroyed")
	is_alive = false
	destruction_countdown = destruction_delay


signal damaged
signal destroyed

const WeaponBase = preload("WeaponBase.gd")
