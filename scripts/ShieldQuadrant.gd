extends Area

onready var mesh: MeshInstance = get_node("mesh")

var flicker_countdown: float = 0.0
var hitpoints: float
var max_hitpoints: float = 100.0
var recovery_boost: int = 0
var recovery_countdown: float = 0.0
var recovery_rate: float # Hitpoints per second


func _ready():
	hitpoints = max_hitpoints
	self.connect("area_entered", self, "_on_area_entered")


func _deal_damage(amount: float):
	hitpoints = max(0, hitpoints - amount)
	flicker_countdown = FLICKER_DELAY
	mesh.show()
	emit_signal("hitpoints_changed", hitpoints / max_hitpoints)


func _on_area_entered(area):
	# Only handle collisions if this shield quadrant is still up
	if hitpoints > 0:
		if area is WeaponBase and area.owner_ship != get_parent():
			_deal_damage(area.damage_shield)
			area.destroy()


func _process(delta):
	if flicker_countdown != 0:
		flicker_countdown -= delta

		var albedo_color = mesh.get_surface_material(0).albedo_color

		albedo_color.a = flicker_countdown / FLICKER_DELAY
		mesh.get_surface_material(0).set_albedo(albedo_color)

		if flicker_countdown <= 0:
			mesh.hide()
			flicker_countdown = 0
			recovery_countdown = RECOVERY_DELAY
	elif recovery_countdown != 0:
		recovery_countdown -= delta

		if recovery_countdown <= 0:
			recovery_countdown = 0
	elif hitpoints < max_hitpoints:
		hitpoints += delta * (recovery_rate + recovery_boost * RECOVERY_BOOST)
		emit_signal("hitpoints_changed", hitpoints / max_hitpoints)

		if hitpoints > max_hitpoints:
			hitpoints = max_hitpoints


# PUBLIC


func get_hitpoints_fraction():
	return hitpoints / max_hitpoints


func set_hitpoints(amount: float):
	hitpoints = clamp(amount, 0, max_hitpoints)
	emit_signal("hitpoints_changed", hitpoints / max_hitpoints)


func set_max_hitpoints(amount: float):
	max_hitpoints = amount
	hitpoints = amount


func set_recovery_boost(boost_direction: int):
	recovery_boost = boost_direction


func set_recovery_rate(system_power: float):
	recovery_rate = MIN_RECOVERY_RATE + system_power * (MAX_RECOVERY_RATE - MIN_RECOVERY_RATE)


static func boost_shield_quadrant(shields: Array, quadrant: int):
	if shields[quadrant].recovery_boost == 1:
		# Reset the boost
		for quadrant in shields:
			quadrant.set_recovery_boost(0)
	else:
		for index in range(shields.size()):
			if index == quadrant:
				shields[index].set_recovery_boost(1)
			else:
				shields[index].set_recovery_boost(-1)


static func equalize_shields(shields: Array):
	var total_hitpoints: float = 0.0
	for quadrant in shields:
		total_hitpoints += quadrant.hitpoints

	for quadrant in shields:
		quadrant.set_hitpoints(total_hitpoints / 4)


static func redirect_hitpoints_to_quadrant(shields: Array, quadrant: int):
	var redirect_amount: float = REDIRECT_FRACTION * shields[quadrant].max_hitpoints
	var previous_hitpoints: float = shields[quadrant].hitpoints
	var new_hitpoints = min(shields[quadrant].max_hitpoints, shields[quadrant].hitpoints + redirect_amount)

	var amount_to_draw: float = new_hitpoints - previous_hitpoints
	if amount_to_draw != 0:
		# Draw hitpoints from other quadrants
		var increment: float = amount_to_draw / 3
		var other_quadrant = (quadrant + 1) % shields.size()
		var step: int = 0
		var max_steps: int = 2 * shields.size()

		while amount_to_draw > 0:
			var previous_quad_hitpoints: float = shields[other_quadrant].hitpoints
			shields[other_quadrant].set_hitpoints(shields[other_quadrant].hitpoints - increment)
			amount_to_draw -= previous_quad_hitpoints - shields[other_quadrant].hitpoints

			# Step to next quadrant
			other_quadrant = (other_quadrant + 1) % shields.size()
			if other_quadrant == quadrant:
				other_quadrant = (other_quadrant + 1) % shields.size()

			step += 1
			if step >= max_steps:
				# Not enough hitpoints from other quadrants; subtract remaining amount to draw from new hitpoints
				new_hitpoints -= amount_to_draw
				break

		shields[quadrant].set_hitpoints(new_hitpoints)


signal hitpoints_changed

const WeaponBase = preload("WeaponBase.gd")

const FLICKER_DELAY: float = 0.45
const MAX_RECOVERY_RATE: float = 10.0
const MIN_RECOVERY_RATE: float = 2.0
const RECOVERY_DELAY: float = 0.85 # Starts after flicker delay
const RECOVERY_BOOST: float = 1.5
const REDIRECT_FRACTION: float = 0.15 # Fraction of max hitpoints to add/subtract when augmenting shields
