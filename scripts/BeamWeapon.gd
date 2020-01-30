extends Spatial

enum { NONE, WARMING_UP, FIRING, COOLING_DOWN }

export (float) var fire_delay = 7.0
export (float) var fire_duration = 3.0
export (float) var hull_damage = 20
export (float) var shield_damage = 50
export (float) var warm_up_duration = 2.0
export (String) var weapon_name = "beam weapon"

onready var beam = get_node("Beam")
onready var beam_sound_player = get_node("Beam Sound Player")
onready var cool_down_player = get_node("Cool Down Player")
onready var core = get_node("Core")
onready var raycast_container = get_node("Raycast Container")
onready var target_raycast = get_node("Raycast Container/RayCast")
onready var timer = get_node("Timer")
onready var warm_up_player = get_node("Warm Up Player")

var beam_vector: Vector3 = Vector3.ONE
var camera: Camera
var current_target
var firing_state: int = NONE
var has_target: bool = false
var target_pos: Vector3


func _ready():
	camera = get_viewport().get_camera()

	timer.connect("timeout", self, "_on_timer_timeout")
	timer.set_wait_time(LOOK_FOR_TARGETS_COUNTDOWN)
	timer.start()

	beam.hide()
	core.hide()


func _on_timer_timeout():
	match firing_state:
		NONE:
			if has_target and is_clear_line_to_target():
				set_firing_state(WARMING_UP)
			else:
				# Look for other targets?
				timer.set_wait_time(LOOK_FOR_TARGETS_COUNTDOWN)
				timer.start()
		WARMING_UP:
			if has_target:
				set_firing_state(FIRING)
			else:
				set_firing_state(COOLING_DOWN)
		FIRING:
			set_firing_state(COOLING_DOWN)
		COOLING_DOWN:
			set_firing_state(NONE)


func _process(delta):
	var countdown = timer.get_time_left()

	match firing_state:
		NONE:
			pass
		WARMING_UP:
			core.set_scale(Vector3.ONE * (1 - (countdown / warm_up_duration)))
		FIRING:
			raycast_container.look_at(target_pos, Vector3.UP)

			if target_raycast.is_colliding():
				var collider = target_raycast.get_collider()

				if collider is ShipBase:
					collider.deal_damage(delta * hull_damage)
				elif collider is ShieldQuadrant:
					var collider_parent = collider.get_parent()

					if collider.hitpoints <= 0:
						if collider_parent is ShipBase:
							collider_parent.deal_damage(delta * hull_damage)
					else:
						collider.deal_damage(delta * shield_damage)

			# TODO: Resize the beam in case another ship crosses it

			beam.look_at(target_pos, camera.transform.basis.x)
			# look_at resets the scale so we have to force it again
			beam.set_scale(beam_vector)

			if not beam.visible:
				beam.show()
		COOLING_DOWN:
			core.set_scale(Vector3.ONE * (countdown / warm_up_duration))


# PUBLIC


func is_clear_line_to_target():
	var to_target_dot = (current_target.transform.origin - global_transform.origin).dot(global_transform.basis.y)
	# Target is below the turret base
	if to_target_dot <= 0:
		return false

	raycast_container.look_at(current_target.transform.origin, Vector3.UP)

	var collider = target_raycast.get_collider()
	if collider != null:
		return collider == current_target or collider.get_parent() == current_target

	return false


func set_firing_state(new_state: int):
	firing_state = new_state

	match firing_state:
		NONE:
			timer.set_wait_time(fire_delay)
			core.hide()
		WARMING_UP:
			timer.set_wait_time(warm_up_duration)
			core.set_scale(Vector3.ZERO)
			core.show()
			warm_up_player.play()
		FIRING:
			timer.set_wait_time(fire_duration)
			# Fire at target's position at this moment, allowing fast ships to evade
			target_pos = current_target.transform.origin
			beam_vector.z = global_transform.origin.distance_to(current_target.transform.origin)
			beam_sound_player.play()
		COOLING_DOWN:
			timer.set_wait_time(warm_up_duration)
			beam.hide()
			beam_sound_player.stop()
			cool_down_player.play()

	timer.start()


func set_target(target_node):
	has_target = true
	current_target = target_node


const ShipBase = preload("ShipBase.gd")
const ShieldQuadrant = preload("ShieldQuadrant.gd")

const LOOK_FOR_TARGETS_COUNTDOWN: float = 2.0
