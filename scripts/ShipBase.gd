extends "res://scripts/ActorBase.gd"

enum { NONE, WARP_IN, WARP_OUT }

export (String) var faction
export (bool) var is_warped_in = true

onready var ship_class: String = get_meta("ship_class")
onready var source_folder = get_meta("source_folder")

var current_target
var has_target: bool = false
var max_speed: float
var propulsion_force: float = 1.0
var target_index: int = 0
var targeting_ships: Array = []
var throttle: float
var torque_vector: Vector3
var turn_speed: float
var warp_destination: Vector3
var warp_origin: Vector3
var warp_speed: float
var warping: int = NONE
var warping_countdown: float = 0.0


func _ready():
	if has_meta("propulsion_force"):
		propulsion_force = get_meta("propulsion_force")
	if has_meta("max_hull_hitpoints"):
		max_hull_hitpoints = get_meta("hull_hitpoints")
	if has_meta("max_speed"):
		max_speed = get_meta("max_speed")

	# Set turn speed based on mass
	turn_speed = 2.5 * mass


func _deselect_current_target():
	has_target = false
	current_target.disconnect("destroyed", self, "_on_target_destroyed")
	current_target.disconnect("warped_out", self, "_on_target_destroyed")
	current_target.handle_target_deselected(self)
	current_target = null


func _get_throttle_to_match_target_speed():
	var target_speed: float = current_target.linear_velocity.length()
	# The target ship might be flying faster than this ship can
	return min(target_speed / get_max_speed(), 1)


func _on_mission_ready():
	._on_mission_ready()

	if not is_warped_in:
		hide_and_disable()


func _on_target_destroyed():
	has_target = false
	current_target = null
	target_index = 0


func _on_targeting_ship_destroyed(destroyed_ship):
	var index: int = 0
	for ship in targeting_ships:
		if ship == destroyed_ship:
			targeting_ships.remove(index)
			return
		index += 1


func _physics_process(delta):
	if warping == NONE:
		add_torque(turn_speed * torque_vector)
		apply_central_impulse(throttle * propulsion_force * -transform.basis.z)


func _process(delta):
	match warping:
		NONE:
			pass
		WARP_IN:
			transform.origin = warp_origin.linear_interpolate(warp_destination, 1 - max(0, warping_countdown / WARP_DURATION))
			warping_countdown -= delta
			if warping_countdown <= 0:
				show_and_enable()
				warping = NONE
				is_warped_in = true
				emit_signal("warped_in")
		WARP_OUT:
			warping_countdown -= delta

			if warping_countdown <= 0:
				translate(delta * warp_speed * Vector3.FORWARD)

				if warping_countdown <= -WARP_DURATION:
					hide_and_disable()
					emit_signal("warped_out")
					queue_free()


func _set_current_target(node):
	if has_target:
		current_target.disconnect("destroyed", self, "_on_target_destroyed")
		current_target.disconnect("warped_out", self, "_on_target_destroyed")
		current_target.handle_target_deselected(self)

	if node.is_alive:
		has_target = true
		current_target = node
		current_target.connect("destroyed", self, "_on_target_destroyed")
		current_target.connect("warped_out", self, "_on_target_destroyed")
		current_target.handle_being_targeted(self)


func _start_destruction():
	var smoke = DESTRUCTION_SMOKE.instance()
	add_child(smoke)

	._start_destruction()


# Loops through the given array of possible targets; if one is found, set it as the current target and return true, otherwise do nothing and return false
func _target_next_of_alignment(alignment: int):
	var possible_targets = mission_controller.get_targets()
	var targets_count = possible_targets.size()
	var steps: int = 0
	if has_target:
		target_index = (target_index + 1) % targets_count
		steps += 1

	# Ensures we loop through all targets just once
	while steps < targets_count:
		var target = possible_targets[target_index]
		if self != target and mission_controller.get_alignment(faction, target.faction) == alignment:
			_set_current_target(target)
			return true

		target_index = (target_index + 1) % targets_count
		steps += 1

	return false


# PUBLIC


func get_max_speed():
	return max_speed


func handle_being_targeted(targeting_ship):
	targeting_ships.append(targeting_ship)
	targeting_ship.connect("destroyed", self, "_on_targeting_ship_destroyed", [ targeting_ship ])
	targeting_ship.connect("warped_out", self, "_on_targeting_ship_destroyed", [ targeting_ship ])


func handle_target_deselected(targeting_ship):
	var index: int = 0
	for ship in targeting_ships:
		if ship == targeting_ship:
			targeting_ships.remove(index)
			return

		index += 1


func hide_and_disable():
	set_process(false)
	_disable_shapes(true)

	hide()


func show_and_enable():
	set_process(true)
	_disable_shapes(false)

	show()


func warp(warp_in: bool):
	if warp_in:
		warping = WARP_IN
		warp_destination = transform.origin
		translate(WARP_IN_DISTANCE * Vector3.BACK)
		warp_origin = transform.origin
		emit_signal("warping_in")

		set_process(true)
		show()
	else:
		warping = WARP_OUT
		warp_speed = WARP_IN_DISTANCE / WARP_DURATION

	warping_countdown = WARP_DURATION


static func get_hitpoints_strength(hitpoints: float):
	if hitpoints < 100:
		return "Low"
	if hitpoints < 200:
		return "Moderate"
	if hitpoints < 300:
		return "High"

	return "Very High"


static func get_weapon_capacity_level(capacity: float):
	if capacity < 50:
		return "Low"
	if capacity < 100:
		return "Moderate"
	if capacity < 150:
		return "High"

	return "Very High"


signal warped_in
signal warped_out
signal warping_in

const ActorBase = preload("ActorBase.gd")

const ACCELERATION: float = 0.1
const DESTRUCTION_SMOKE = preload("res://models/Destruction_Smoke.tscn")
const MAX_THROTTLE: float = 1.0
const WARP_DURATION: float = 2.5
const WARP_IN_DISTANCE: float = 400.0
