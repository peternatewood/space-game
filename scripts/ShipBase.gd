extends KinematicBody

enum { NONE, WARP_IN, WARP_OUT }
enum { WEAPON, SHIELD, ENGINE, TOTAL_POWER_LEVELS }
enum { FRONT, REAR, LEFT, RIGHT }

export (String) var faction
export (float) var hull_hitpoints = -1
export (bool) var is_warped_in = true
export (String) var wing_name

onready var chase_view = get_node("Chase View")
onready var cockpit_view = get_node("Cockpit View")
onready var collision_sound_player = get_node_or_null("Collision Sound Player")
onready var engine_loop_player = get_node_or_null("Engine Loop")
onready var exhaust = get_node("Exhaust")
onready var mission_controller = get_tree().get_root().get_node_or_null("Mission Controller")
onready var settings = get_node("/root/GlobalSettings")
onready var target_raycast = get_node("Target Raycast")
onready var warp_boom_player = get_node("Warp Boom Player")
onready var warp_ramp_up_player = get_node("Warp Ramp Up Player")

var angular_velocity: Vector3
var beam_weapon_turrets: Array = []
var bounding_box_extents = get_meta("bounding_box_extents")
var cam_distance: float = get_meta("cam_distance")
var current_subsystem
var current_subsystem_index: int = -1
var current_target
var destruction_delay: float = 0.0
var energy_weapon_hardpoints: Array = []
var energy_weapon_index: int = 0
var energy_weapon_turrets: Array = []
var engines_operative: bool = true
var has_collision_sound: bool = false
var has_engine_loop: bool = false
var has_target: bool = false
var has_warp_boom: bool = false
var has_warp_ramp_up: bool = false
var input_velocity: Vector3
var is_alive: bool = true
var is_capital_ship: bool = get_meta("is_capital_ship")
var last_speed: float = 0.0
var last_speed_sq: float = 0.0
var linear_velocity: Vector3
var mass = get_meta("mass")
var max_hull_hitpoints: float = get_meta("hull_hitpoints")
var max_speed: float = get_meta("max_speed")
var missile_weapon_hardpoints
var missile_weapon_index: int = 0
var missile_weapon_turrets: Array = []
var power_distribution: Array = [
	float(TOTAL_SYSTEM_POWER / 3),
	float(TOTAL_SYSTEM_POWER / 3),
	float(TOTAL_SYSTEM_POWER / 3)
]
var propulsion_force: float = get_meta("propulsion_force")
var shields: Array = []
var ship_class: String = get_meta("ship_class")
var source_folder = get_meta("source_folder")
var subsystems: Dictionary = {}
var target_index: int = 0
var targeting_ships: Array = []
var throttle: float = 0.0 setget set_throttle
var turn_speed: Vector3 = get_meta("turn_speed")
var warp_destination: Vector3
var warp_origin: Vector3
var warp_speed: float
var warping: int = NONE
var warping_countdown: float = 0.0
var weapon_battery: float = MAX_WEAPON_BATTERY


func _ready():
	if get_meta("has_beam_weapon_turrets"):
		beam_weapon_turrets = get_node("Beam Weapon Turrets").get_children()
	if get_meta("has_energy_weapon_turrets"):
		energy_weapon_turrets = get_node("Energy Weapon Turrets").get_children()
	if get_meta("has_missile_weapon_turrets"):
		missile_weapon_turrets = get_node("Missile Weapon Turrets").get_children()

	for turret in beam_weapon_turrets:
		turret.hull_hitpoints = turret.max_hull_hitpoints
		turret.add_collision_exception_with(self)
		self.add_collision_exception_with(turret)

	for turret in energy_weapon_turrets:
		turret.hull_hitpoints = turret.max_hull_hitpoints
		turret.add_collision_exception_with(self)
		self.add_collision_exception_with(turret)

	for turret in missile_weapon_turrets:
		turret.hull_hitpoints = turret.max_hull_hitpoints
		turret.add_collision_exception_with(self)
		self.add_collision_exception_with(turret)

	if not is_capital_ship:
		energy_weapon_hardpoints = get_node("Energy Weapon Groups").get_children()
		missile_weapon_hardpoints = get_node("Missile Weapon Groups").get_children()

		shields = [
			get_node_or_null("Shield Front"),
			get_node_or_null("Shield Rear"),
			get_node_or_null("Shield Left"),
			get_node_or_null("Shield Right")
		]

		var shield_hitpoints = get_meta("shield_hitpoints")
		for quadrant in shields:
			quadrant.set_max_hitpoints(shield_hitpoints)
			quadrant.set_recovery_rate(power_distribution[SHIELD] / MAX_SYSTEM_POWER)

	# Get subsystem nodes
	var subsystems_container = get_node_or_null("Subsystems")
	if subsystems_container == null:
		print(name, " missing subsystems container!")
	else:
		var communications_node = subsystems_container.get_node_or_null("Communications")
		if communications_node == null:
			print(name, " missing communications subsystem node!")
		else:
			communications_node.owner_ship = self
			communications_node.connect("damaged", self, "_on_subsystem_damaged")
			communications_node.connect("destroyed", self, "_on_subsystem_destroyed")
			subsystems["Communications"] = communications_node

		var engines_node = subsystems_container.get_node_or_null("Engines")
		if engines_node == null:
			print(name, " missing engines subsystem node!")
		else:
			engines_node.owner_ship = self
			engines_node.connect("damaged", self, "_on_subsystem_damaged")
			engines_node.connect("destroyed", self, "_on_subsystem_destroyed")
			subsystems["Engines"] = engines_node

		var navigation_node = subsystems_container.get_node_or_null("Navigation")
		if navigation_node == null:
			print(name, " missing navigation subsystem node!")
		else:
			navigation_node.owner_ship = self
			navigation_node.connect("damaged", self, "_on_subsystem_damaged")
			navigation_node.connect("destroyed", self, "_on_subsystem_destroyed")
			subsystems["Navigation"] = navigation_node

		var sensors_node = subsystems_container.get_node_or_null("Sensors")
		if sensors_node == null:
			print(name, " missing sensors subsystem node!")
		else:
			sensors_node.owner_ship = self
			sensors_node.connect("damaged", self, "_on_subsystem_damaged")
			sensors_node.connect("destroyed", self, "_on_subsystem_destroyed")
			subsystems["Sensors"] = sensors_node

		var weapons_node = subsystems_container.get_node_or_null("Weapons")
		if weapons_node == null:
			print(name, " missing weapons subsystem node!")
		else:
			weapons_node.owner_ship = self
			weapons_node.connect("damaged", self, "_on_subsystem_damaged")
			weapons_node.connect("destroyed", self, "_on_subsystem_destroyed")
			subsystems["Weapons"] = weapons_node

	destruction_delay = 2.0

	has_engine_loop = engine_loop_player != null
	has_warp_boom = warp_boom_player != null
	has_warp_ramp_up = warp_ramp_up_player != null

	if mission_controller != null:
		mission_controller.connect("mission_ready", self, "_on_mission_ready")

		has_collision_sound = collision_sound_player != null

	set_process(false)


func _cycle_energy_weapon(direction: int):
	energy_weapon_index = (energy_weapon_index + direction) % energy_weapon_hardpoints.size()

	# Skip any weapon slot that has no weapon loaded
	var index: int = 0
	while not energy_weapon_hardpoints[energy_weapon_index].is_weapon_loaded and index < energy_weapon_hardpoints.size():
		energy_weapon_index = (energy_weapon_index + direction) % energy_weapon_hardpoints.size()
		index += 1

	emit_signal("energy_weapon_changed")


func _cycle_missile_weapon(direction: int):
	missile_weapon_index = (missile_weapon_index + direction) % missile_weapon_hardpoints.size()

	# Skip any weapon slot that has no weapon loaded
	var index: int = 0
	while not missile_weapon_hardpoints[missile_weapon_index].is_weapon_loaded and index < missile_weapon_hardpoints.size():
		missile_weapon_index = (missile_weapon_index + direction) % missile_weapon_hardpoints.size()
		index += 1

	emit_signal("missile_weapon_changed")


func _cycle_target_subsystems():
	if has_target:
		var target_subsystems_count: int = current_target.subsystems.size()

		if target_subsystems_count > 0:
			current_subsystem_index = (current_subsystem_index + 1) % target_subsystems_count
			current_subsystem = current_target.subsystems[current_target.subsystems.keys()[current_subsystem_index]]

			emit_signal("subsystem_targeted")


func _disable_shapes(disable: bool):
	for child in get_children():
		if child is CollisionShape:
			child.set_disabled(disable)


func _deselect_current_target():
	has_target = false
	current_target.disconnect("destroyed", self, "_on_target_destroyed")
	current_target.disconnect("warped_out", self, "_on_target_destroyed")
	current_target.handle_target_deselected(self)
	current_target = null


func _deselect_target_subsystem():
	if has_target:
		current_subsystem_index = -1
		current_subsystem = null

		emit_signal("subsystem_deselected")


func _destroy():
	# Generate debris
	if has_node("Debris"):
		for node in get_node("Debris").get_children():
			var debris = DEBRIS_PREFAB.instance()

			var debris_mesh = node.get_node("Mesh").duplicate(DUPLICATE_USE_INSTANCING)
			debris.add_child(debris_mesh)
			debris_mesh.transform = Transform.IDENTITY
			var debris_collider = node.get_node("Collision Shape").duplicate(DUPLICATE_USE_INSTANCING)
			debris.add_child(debris_collider)
			debris_collider.transform = Transform.IDENTITY
			debris_collider.set_disabled(false)

			debris.set_mass(mass)
			mission_controller.add_child(debris)
			debris.transform = node.global_transform

		_disable_shapes(true)

	var explosion

	if is_capital_ship:
		explosion = LARGE_EXPLOSION_PREFAB.instance()
	else:
		explosion = EXPLOSION_PREFAB.instance()

	explosion.transform.origin = transform.origin
	mission_controller.add_child(explosion)

	queue_free()


func _fire_energy_weapon():
	var weapon_cost = energy_weapon_hardpoints[energy_weapon_index].weapon_data.get("cost", 1.0)
	if energy_weapon_hardpoints[energy_weapon_index].countdown == 0 and weapon_battery >= weapon_cost:
		energy_weapon_hardpoints[energy_weapon_index].fire_weapon(self)
		weapon_battery -= weapon_cost

		return true

	return false


func _fire_missile_weapon(target = null):
	if missile_weapon_hardpoints[missile_weapon_index].countdown == 0 and missile_weapon_hardpoints[missile_weapon_index].ammo_count > 0:
		missile_weapon_hardpoints[missile_weapon_index].fire_missile_weapon(self, target)
		# TODO: subtract from missile weapon ammo

		return true

	return false


# Ranges from 0.75 to 1.25
func _get_engine_factor():
	if is_capital_ship:
		return 1.0

	return 0.75 + 0.5 * (power_distribution[ENGINE] / MAX_SYSTEM_POWER)


func _get_throttle_to_match_target_speed():
	var target_speed: float = current_target.linear_velocity.length()
	# The target ship might be flying faster than this ship can
	return min(target_speed / get_max_speed(), 1)


func _increment_power_level(system: int, direction: int):
	if system >= 0 and system < TOTAL_POWER_LEVELS:
		var previous_level: float = power_distribution[system]
		power_distribution[system] = clamp(previous_level + direction * POWER_INCREMENT, 0, MAX_SYSTEM_POWER)

		var power_diff: float = abs(previous_level - power_distribution[system])
		if power_diff != 0:
			# Redistribute power to other systems
			var increment = power_diff / 2
			var other_system: int = (system + 1) % TOTAL_POWER_LEVELS
			var steps: int = 0

			while power_diff != 0:
				previous_level = power_distribution[other_system]
				power_distribution[other_system] = clamp(previous_level - direction * min(increment, power_diff), 0, MAX_SYSTEM_POWER)
				power_diff -= abs(power_distribution[other_system] - previous_level)

				other_system = (other_system + 1) % TOTAL_POWER_LEVELS
				if other_system == system:
					other_system = (other_system + 1) % TOTAL_POWER_LEVELS

				steps += 1
				if steps > 10:
					print("Too many steps!")
					return

			# Update shields' recovery rate
			for quadrant in shields:
				quadrant.set_recovery_rate(power_distribution[SHIELD] / MAX_SYSTEM_POWER)


func _on_mission_ready():
	if has_engine_loop:
		connect("speed_changed", self, "_on_speed_changed")
		_on_speed_changed(0.0)
		engine_loop_player.play()

	for turret in beam_weapon_turrets:
		turret._on_mission_ready()

	for turret in energy_weapon_turrets:
		turret._on_mission_ready()

	for turret in missile_weapon_turrets:
		turret._on_mission_ready()

	if hull_hitpoints < 0:
		hull_hitpoints = max_hull_hitpoints

	set_process(true)

	if not is_warped_in:
		hide_and_disable()


func _on_speed_changed(speed: float):
	if has_engine_loop:
		var speed_percent = 100 * speed / get_max_speed()

		engine_loop_player.set_unit_db(MathHelper.percent_to_db(speed_percent))


func _on_subsystem_damaged(category: int, hitpoints_percent: float):
	emit_signal("subsystem_damaged", category, hitpoints_percent)


func _on_subsystem_destroyed(category: int):
	match category:
		1:
			self.throttle = 0
			input_velocity = Vector3.ZERO
		3:
			has_target = false
			emit_signal("target_changed", current_target)
			current_target = null

	emit_signal("subsystem_destroyed", category)


func _on_target_destroyed():
	has_target = false
	current_target = null
	target_index = 0
	current_subsystem_index = -1


func _on_targeting_ship_destroyed(destroyed_ship):
	var index: int = 0
	for ship in targeting_ships:
		if ship == destroyed_ship:
			targeting_ships.remove(index)
			return
		index += 1


func _physics_process(delta):
	if warping == NONE:
		var collision = move_and_collide(delta * linear_velocity)
		rotate(transform.basis.x, delta * angular_velocity.x)
		rotate(transform.basis.y, delta * angular_velocity.y)
		rotate(transform.basis.z, delta * angular_velocity.z)

		if collision != null:
			collision.collider.deal_damage(1)
			deal_damage(1)
			linear_velocity = collision.normal


func _process(delta):
	match warping:
		NONE:
			if weapon_battery < MAX_WEAPON_BATTERY:
				# Ranges from half recovery rate to full recovery rate (0.5 - 1.0)
				var battery_recovery_rate: float = WEAPON_BATTERY_RECOVERY_RATE * (0.5 + 0.5 * power_distribution[WEAPON] / MAX_SYSTEM_POWER)
				weapon_battery = min(MAX_WEAPON_BATTERY, weapon_battery + delta * battery_recovery_rate)

			linear_velocity = linear_velocity.linear_interpolate(-transform.basis.z * throttle * get_max_speed(), delta)
			angular_velocity.x = lerp(angular_velocity.x, turn_speed.x * input_velocity.x, delta)
			angular_velocity.y = lerp(angular_velocity.y, turn_speed.y * input_velocity.y, delta)
			angular_velocity.z = lerp(angular_velocity.z, turn_speed.z * input_velocity.z, delta)

			# Update thruster exhaust scale
			if exhaust.scale.z != throttle:
				var z_scale: float = lerp(exhaust.scale.z, throttle, delta)
				if abs(throttle - z_scale) < 0.01:
					z_scale = throttle

				exhaust.set_scale(Vector3(1, 1, z_scale))
		WARP_IN:
			transform.origin = warp_origin.linear_interpolate(warp_destination, 1 - max(0, warping_countdown / WARP_DURATION))
			warping_countdown -= delta
			if warping_countdown <= 0:
				show_and_enable()
				warping = NONE
				is_warped_in = true

				if has_warp_boom:
					warp_boom_player.play()
				else:
					print("Missing warp boom sound")

				emit_signal("warped_in")
		WARP_OUT:
			var ramping_up: bool = warping_countdown > 0
			warping_countdown -= delta

			if warping_countdown <= 0:
				if ramping_up:
					emit_signal("warping_ramped_up")

					if has_warp_boom:
						warp_boom_player.play()
					else:
						print("Missing warp boom sound")

				translate(delta * warp_speed * Vector3.FORWARD)

				if warping_countdown <= -WARP_DURATION:
					hide_and_disable()
					emit_signal("warped_out")
					queue_free()

	var speed_squared = linear_velocity.length_squared()
	if speed_squared - last_speed_sq > pow(last_speed + 1, 2) - last_speed_sq or last_speed_sq - speed_squared > last_speed_sq - pow(last_speed - 1, 2):
		last_speed_sq = speed_squared
		last_speed = sqrt(speed_squared)
		emit_signal("speed_changed", last_speed)


func _set_current_target(node):
	_deselect_target_subsystem()

	if has_target:
		current_target.disconnect("destroyed", self, "_on_target_destroyed")
		current_target.disconnect("warped_out", self, "_on_target_destroyed")
		current_target.handle_target_deselected(self)

	if subsystems["Sensors"].operative and node.is_alive:
		has_target = true
		current_target = node
		current_target.connect("destroyed", self, "_on_target_destroyed")
		current_target.connect("warped_out", self, "_on_target_destroyed")
		current_target.handle_being_targeted(self)

		for turret in beam_weapon_turrets:
			turret.set_target(node)
		for turret in energy_weapon_turrets:
			turret.set_target(node)
		for turret in missile_weapon_turrets:
			turret.set_target(node)


func _start_destruction():
	var smoke = DESTRUCTION_SMOKE.instance()
	add_child(smoke)

	is_alive = false
	set_process(false)

	var destruction_timer = Timer.new()
	destruction_timer.set_one_shot(true)
	destruction_timer.set_autostart(true)
	destruction_timer.set_wait_time(destruction_delay)
	destruction_timer.connect("timeout", self, "_destroy")
	mission_controller.add_child(destruction_timer)

	emit_signal("destroyed")


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


func deal_damage(amount: float):
	if hull_hitpoints > 0:
		hull_hitpoints -= amount
		emit_signal("damaged")

		if hull_hitpoints <= 0:
			_start_destruction()


func get_armed_energy_weapon_speed():
	return energy_weapon_hardpoints[energy_weapon_index].weapon_data.get("speed", 0)


func get_bounding_box():
	var vertices: Array = []
	for vertex in bounding_box_extents:
		vertices.append(global_transform.xform(vertex))

	return vertices


func get_energy_weapon_range():
	return energy_weapon_hardpoints[energy_weapon_index].weapon_data("firing_range", 10)


func get_hull_percent():
	return 100 * float(hull_hitpoints) / float(max_hull_hitpoints)


func get_max_speed():
	return max_speed * _get_engine_factor()


func get_overhead_icon():
	if source_folder != null:
		return load(source_folder + "/overhead.png")

	return null


func get_source_filename():
	return get_meta("source_file")


func get_targeting_endpoint():
	if is_a_target_in_range():
		return target_raycast.get_collision_point()

	return cockpit_view.global_transform.origin - 20 * transform.basis.z


func get_weapon_battery_percent():
	return weapon_battery / MAX_WEAPON_BATTERY


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
	for quadrant in shields:
		quadrant.set_monitorable(false)
		quadrant.set_monitoring(false)

	set_process(false)
	_disable_shapes(true)

	hide()


func is_a_target_in_range():
	return target_raycast.get_collider() is PhysicsBody


func set_throttle(amount: float):
	if subsystems["Engines"].operative:
		throttle = amount


func set_weapon_hardpoints(energy_weapons: Array, missile_weapons: Array):
	for index in range(energy_weapons.size()):
		if index < energy_weapon_hardpoints.size():
			energy_weapon_hardpoints[index].set_weapon(energy_weapons[index])
		else:
		 break

	for index in range(missile_weapons.size()):
		if index < missile_weapon_hardpoints.size():
			missile_weapon_hardpoints[index].set_weapon(missile_weapons[index], get_meta("missile_capacity"))
		else:
		 break


func set_weapon_turrets(beam_weapons: Array = [], energy_weapons: Array = [], missile_weapons: Array = []):
	if beam_weapons.size() == beam_weapon_turrets.size():
		for index in range(beam_weapons.size()):
			beam_weapon_turrets[index].set_weapon(beam_weapons[index])

	if energy_weapons.size() == energy_weapon_turrets.size():
		for index in range(energy_weapons.size()):
			energy_weapon_turrets[index].set_weapon(energy_weapons[index])

	if missile_weapons.size() == missile_weapon_turrets.size():
		for index in range(missile_weapons.size()):
			missile_weapon_turrets[index].set_weapon(missile_weapons[index])


func show_and_enable():
	for quadrant in shields:
		quadrant.set_monitorable(true)
		quadrant.set_monitoring(true)

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


signal damaged
signal destroyed
signal energy_weapon_changed
signal missile_weapon_changed
signal speed_changed
signal subsystem_damaged
signal subsystem_deselected
signal subsystem_destroyed
signal subsystem_targeted
signal warped_in
signal warped_out
signal warping_in
signal warping_ramped_up

const MathHelper = preload("MathHelper.gd")

const ACCELERATION: float = 0.1
const DESTRUCTION_SMOKE = preload("res://models/Destruction_Smoke.tscn")
const DEBRIS_PREFAB = preload("res://prefabs/ship_debris.tscn")
const EXPLOSION_PREFAB = preload("res://prefabs/ship_explosion.tscn")
const LARGE_EXPLOSION_PREFAB = preload("res://prefabs/capital_ship_explosion.tscn")
const MAX_SYSTEM_POWER: float = 60.0
const MAX_THROTTLE: float = 1.0
const MAX_WEAPON_BATTERY: float = 100.0
const POWER_INCREMENT: int = 10
const TOTAL_SYSTEM_POWER: float = 90.0
const WARP_DURATION: float = 2.5
const WARP_IN_DISTANCE: float = 400.0
const WEAPON_BATTERY_RECOVERY_RATE: float = 1.0
