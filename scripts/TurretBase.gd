extends Area

export (int) var hull_hitpoints = -1

onready var bounding_box_extents = get_meta("bounding_box_extents")
onready var cam_distance: float = get_meta("cam_distance")
onready var capital_ship = get_parent().get_parent()
onready var max_hull_hitpoints: int = get_meta("hull_hitpoints")
onready var mission_controller = get_node_or_null("/root/Mission Controller")
onready var settings = get_node("/root/GlobalSettings")
onready var turret_base = get_node("Turret Base")

var current_target
var destruction_countdown: float
var destruction_delay: float = 0.0
var fire_countdown: float = 0
var firing_range: float = 0
var has_target: bool = false
var is_alive: bool = true
var is_weapon_loaded: bool = false
var weapon


func _ready():
	self.connect("body_entered", self, "_on_body_entered")

	if mission_controller != null:
		mission_controller.connect("mission_ready", self, "_on_mission_ready")

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
	elif body != capital_ship:
		_deal_damage(1)


func _on_mission_ready():
	if hull_hitpoints < 0:
		hull_hitpoints = max_hull_hitpoints

	set_process(true)


func _on_target_destroyed():
	has_target = false
	current_target = null


func _point_at_target(delta):
	pass


func _process(delta):
	if is_alive:
		if fire_countdown > 0:
			fire_countdown -= delta

		if has_target:
			_point_at_target(delta)
	else:
		destruction_countdown -= delta
		if destruction_countdown <= 0:
			set_process(false)
			_destroy()


func _start_destruction():
	is_alive = false
	destruction_countdown = destruction_delay
	emit_signal("destroyed")


# PUBLIC


func get_bounding_box():
	var vertices: Array = []
	for vertex in bounding_box_extents:
		vertices.append(global_transform.xform(vertex))

	return vertices


func get_hull_percent():
	return 100 * float(hull_hitpoints) / float(max_hull_hitpoints)


func is_target_in_range():
	return has_target and (current_target.transform.origin - global_transform.origin).length_squared() <= firing_range * firing_range


func set_target(target = null):
	has_target = target != null
	current_target = target

	target.connect("destroyed", self, "_on_target_destroyed")


func set_weapon(weapon_scene):
	if weapon_scene != null:
		is_weapon_loaded = true
		weapon = weapon_scene

		var weapon_instance = weapon.instance()
		firing_range = weapon_instance.firing_range
		weapon_instance.free()


signal damaged
signal destroyed

const WeaponBase = preload("WeaponBase.gd")
