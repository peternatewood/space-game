extends RigidBody

export (int) var hull_hitpoints

onready var bounding_box_extents = get_meta("bounding_box_extents")
onready var loader = get_node("/root/SceneLoader")
onready var mission_controller = get_tree().get_root().get_node("Mission Controller")

var destruction_countdown: float
var destruction_delay: float = 0.0
var is_alive: bool = true
var max_hull_hitpoints: int = 100


func _ready():
	self.connect("body_entered", self, "_on_body_entered")
	loader.connect("scene_loaded", self, "_on_scene_loaded")

	set_process(false)


func _deal_damage(amount: int):
	hull_hitpoints -= amount
	emit_signal("damaged")
	if hull_hitpoints <= 0:
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
	if not hull_hitpoints:
		hull_hitpoints = max_hull_hitpoints
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


# PUBLIC


func get_bounding_box():
	var vertices: Array = []
	for vertex in bounding_box_extents:
		vertices.append(global_transform.xform(vertex))

	return vertices


func get_hull_percent():
	return 100 * float(hull_hitpoints) / float(max_hull_hitpoints)


signal damaged
signal destroyed

const WeaponBase = preload("WeaponBase.gd")
