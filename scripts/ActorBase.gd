extends RigidBody

export (float) var hull_hitpoints = -1

onready var bounding_box_extents = get_meta("bounding_box_extents")
onready var cam_distance: float = get_meta("cam_distance")
onready var collision_sound_player = get_node_or_null("Collision Sound Player")
onready var max_hull_hitpoints: float = get_meta("hull_hitpoints")
onready var mission_controller = get_tree().get_root().get_node_or_null("Mission Controller")
onready var settings = get_node("/root/GlobalSettings")

var destruction_delay: float = 0.0
var has_collision_sound: bool = false
var is_alive: bool = true


func _ready():
	if mission_controller != null:
		self.connect("body_entered", self, "_on_body_entered")
		mission_controller.connect("mission_ready", self, "_on_mission_ready")

		has_collision_sound = collision_sound_player != null

	set_process(false)


func _deal_damage(amount: float):
	if hull_hitpoints > 0:
		hull_hitpoints -= amount
		emit_signal("damaged")
		if hull_hitpoints <= 0:
			_start_destruction()


func _destroy():
	queue_free()


func _disable_shapes(disable: bool):
	for child in get_children():
		if child is CollisionShape:
			child.set_disabled(disable)


func _on_body_entered(body):
	if body is WeaponBase:
		_deal_damage(body.damage_hull)
		body.destroy()
	else:
		if has_collision_sound:
			collision_sound_player.play()
		else:
			print("collision sound player missing")

		_deal_damage(1)


func _on_mission_ready():
	if hull_hitpoints < 0:
		hull_hitpoints = max_hull_hitpoints
	set_process(true)


func _start_destruction():
	is_alive = false
	set_process(false)
	var destruction_timer = Timer.new()
	destruction_timer.set_one_shot(true)
	destruction_timer.set_autostart(true)
	destruction_timer.set_wait_time(destruction_delay)
	destruction_timer.connect("timeout", self, "_destroy")
	mission_controller.add_child(destruction_timer)
	emit_signal("destroyed")


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

const MathHelper = preload("MathHelper.gd")
const WeaponBase = preload("WeaponBase.gd")
