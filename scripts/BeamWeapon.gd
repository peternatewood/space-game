extends Spatial

enum { NONE, WARMING_UP, FIRING, COOLING_DOWN }

export (float) var fire_delay = 7.0
export (float) var fire_duration = 3.0
export (float) var hull_damage = 20
export (float) var shield_damage = 50
export (float) var warm_up_duration = 2.0
export (String) var weapon_name = "beam weapon"

onready var beam = get_node("Beam")
onready var core = get_node("Core")
onready var raycast_container = get_node("Raycast Container")
onready var target_raycast = get_node("Raycast Container/RayCast")

var beam_vector: Vector3 = Vector3.ONE
var camera: Camera
var countdown: float
var current_target
var firing_state: int = NONE
var has_target: bool = false
var target_pos: Vector3


func _ready():
	camera = get_viewport().get_camera()

	beam.hide()
	core.hide()


func _process(delta):
	if has_target:
		if countdown > 0:
			countdown -= delta

		match firing_state:
			NONE:
				if countdown <= 0:
					if is_clear_line_to_target():
						set_firing_state(WARMING_UP)
					else:
						# Look for other targets?
						pass
			WARMING_UP:
				core.set_scale(Vector3.ONE * (1 - (countdown / warm_up_duration)))

				if countdown <= 0:
					set_firing_state(FIRING)
			FIRING:
				raycast_container.look_at(target_pos, Vector3.UP)

				if target_raycast.is_colliding():
					var collider = target_raycast.get_collider()

					if collider is ActorBase:
						collider._deal_damage(delta * hull_damage)
					elif collider is ShieldQuadrant:
						var collider_parent = collider.get_parent()

						if collider.hitpoints <= 0:
							if collider_parent is ActorBase:
								collider_parent._deal_damage(delta * hull_damage)
						else:
							collider._damage(delta * shield_damage)

				# TODO: Resize the beam in case another ship crosses it

				beam.look_at(target_pos, camera.transform.basis.x)
				# look_at resets the scale so we have to force it again
				beam.set_scale(beam_vector)

				if not beam.visible:
					beam.show()

				if countdown <= 0:
					set_firing_state(COOLING_DOWN)
			COOLING_DOWN:
				core.set_scale(Vector3.ONE * (countdown / warm_up_duration))

				if countdown <= 0:
					set_firing_state(NONE)


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
			countdown += fire_delay
			core.hide()
		WARMING_UP:
			countdown += warm_up_duration
			core.set_scale(Vector3.ZERO)
			core.show()
		FIRING:
			countdown += fire_duration
			# Fire at target's position at this moment, allowing fast ships to evade
			target_pos = current_target.transform.origin
			beam_vector.z = global_transform.origin.distance_to(current_target.transform.origin)
		COOLING_DOWN:
			countdown += warm_up_duration
			beam.hide()


func set_target(target_node):
	has_target = true
	current_target = target_node


const ActorBase = preload("ActorBase.gd")
const ShieldQuadrant = preload("ShieldQuadrant.gd")
