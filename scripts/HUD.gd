extends Control

export (NodePath) var camera_path
export (NodePath) var player_path

onready var debug = get_node("Debug")
onready var edge_target_icon = get_node("Edge Target Icon")
onready var energy_weapon_rows = get_node("Weapons Container/Weapons Rows/Energy Weapons").get_children()
onready var hud_bars = get_node("HUD Bars")
onready var in_range_icon = get_node("Target Reticule/In Range Indicator")
onready var missile_weapon_rows = get_node("Weapons Container/Weapons Rows/Missile Weapons").get_children()
onready var mission_controller = get_tree().get_root().get_node("Mission Controller")
onready var mission_timer = get_node("Mission Timer")
onready var objectives_rows = get_node("Objectives Container/Objective Rows")
onready var player_overhead = get_node("Player Overhead")
onready var player_hull_bar = get_node("Hull Bar")
onready var power_container = get_node("Power Container")
onready var radar = get_node("Radar")
onready var speed_indicator = get_node("Throttle Bar Container/Speed Indicator")
onready var target_details_minimal = get_node("Target Details Minimal")
onready var target_icon = get_node("Target Icon")
onready var target_overhead = get_node("Target Overhead")
onready var target_reticule = get_node("Target Reticule")
onready var target_reticule_outer = get_node("Target Reticule Outer")
onready var target_view_container = get_node("Target View Container")
onready var target_viewport = get_node("Target Viewport")
onready var throttle_bar = get_node("Throttle Bar Container/Throttle Bar")
onready var throttle_line = get_node("Throttle Bar Container/Throttle Line")
onready var viewport = get_viewport()
onready var weapon_battery_bar = get_node("Weapon Battery Bar")

var camera
var energy_hardpoint_count: int
var missile_hardpoint_count: int
var player
var radar_icons_container: Control
var target_class
var target_distance
var target_hull
var target_name
var target_speed
var target_view_cam
var target_view_model


func _ready():
	radar_icons_container = radar.get_node("Radar Icons Container")
	target_class = target_view_container.get_node("Target View Rows/Target Class")
	target_distance = target_view_container.get_node("Target View Rows/Target Distance Container/Target Distance")
	target_hull = target_view_container.get_node("Target View Rows/Target View Panel Container/Target Hull Container/Target Hull")
	target_name = target_view_container.get_node("Target View Rows/Target Name")
	target_speed = target_view_container.get_node("Target View Rows/Target Distance Container/Target Speed")
	target_view_cam = target_viewport.get_node("Camera")
	target_view_model = target_viewport.get_node("Frog Fighter")

	mission_controller.connect("mission_ready", self, "_on_mission_ready")
	set_process(false)


func _disconnect_target_signals(target):
	target.disconnect("damaged", self, "_on_target_damaged")
	target.disconnect("destroyed", self, "_on_target_destroyed")
	target.disconnect("warped_out", self, "_on_target_destroyed")

	for index in range(target.QUADRANT_COUNT):
		target.shields[index].disconnect("hitpoints_changed", self, "_on_target_shield_changed")


func _on_player_ammo_count_changed(ammo_count: int, index: int):
	missile_weapon_rows[index].set_ammo(ammo_count)


func _on_player_cam_changed(cam_mode: int):
	if cam_mode == player.COCKPIT:
		hud_bars.show()
		target_reticule.set_position(viewport.get_visible_rect().size / 2)
		target_reticule_outer.set_position(target_reticule.rect_position)
	else:
		hud_bars.hide()


func _on_player_damaged():
	player_hull_bar.set_value(player.hull_hitpoints)


func _on_player_destroyed():
	hide()
	set_process(false)


func _on_player_energy_weapon_changed():
	energy_hardpoint_count = player.energy_weapon_hardpoints.size()
	for index in range(energy_weapon_rows.size()):
		energy_weapon_rows[index].toggle_arrow(index == player.energy_weapon_index)


func _on_player_missile_weapon_changed():
	missile_hardpoint_count = player.missile_weapon_hardpoints.size()
	for index in range(missile_weapon_rows.size()):
		missile_weapon_rows[index].toggle_arrow(index == player.missile_weapon_index)


func _on_player_power_distribution_changed():
	power_container.set_power_bars(player.power_distribution)


func _on_player_shield_changed(percent: float, quadrant: int):
	player_overhead.set_shield_alpha(quadrant, percent)


func _on_player_shield_boost_changed():
	player_overhead.set_shield_boosted(player.shields)


func _on_player_target_changed(last_target):
	var radar_icons = radar_icons_container.get_children()

	# Disconnect signals from old target
	if last_target != null:
		_disconnect_target_signals(last_target)

		for icon in radar_icons:
			icon.set_modulate(ALIGNMENT_COLORS_FADED[mission_controller.get_alignment(player.faction, icon.target.faction)])

	if player.has_target:
		target_viewport.remove_child(target_view_model)
		# Duplicating the target node turns out to be much faster than trying to load a new model, though the viewport is blank for a second or two
		target_view_model = player.current_target.duplicate(Node.DUPLICATE_USE_INSTANCING)

		var overhead_icon = player.current_target.get_overhead_icon()
		if overhead_icon == null:
			print("Missing overhead icon for " + player.current_target.name)
			return

		player.current_target.connect("damaged", self, "_on_target_damaged")
		player.current_target.connect("destroyed", self, "_on_target_destroyed", [ player.current_target ])
		player.current_target.connect("warped_out", self, "_on_target_destroyed", [ player.current_target ])

		for index in range(player.current_target.QUADRANT_COUNT):
			player.current_target.shields[index].connect("hitpoints_changed", self, "_on_target_shield_changed", [ index ])
			# Also update the icons manually
			_on_target_shield_changed(player.current_target.shields[index].get_hitpoints_fraction(), index)

		# Update icons
		target_overhead.set_overhead_icon(overhead_icon)

		var alignment = mission_controller.get_alignment(player.faction, player.current_target.faction)
		for icon in radar_icons:
			if icon.target == player.current_target:
				icon.set_modulate(Color.white if alignment == -1 else ALIGNMENT_COLORS[alignment])
				break

		if alignment != -1:
			target_name.set_modulate(ALIGNMENT_COLORS[alignment])
			target_class.set_modulate(ALIGNMENT_COLORS[alignment])
			edge_target_icon.set_modulate(ALIGNMENT_COLORS[alignment])
			target_icon.set_modulate(ALIGNMENT_COLORS[alignment])
		else:
			target_name.set_modulate(Color.white)
			target_class.set_modulate(Color.white)
			edge_target_icon.set_modulate(Color.white)
			target_icon.set_modulate(Color.white)

		if not target_details_minimal.visible:
			target_details_minimal.show()

		target_details_minimal.set_hull(player.current_target.get_hull_percent())
		for index in range(player.current_target.QUADRANT_COUNT):
			target_details_minimal.set_shield_alpha(index, player.current_target.shields[index].get_hitpoints_fraction())

		# Update target viewport
		target_class.set_text(player.current_target.ship_class)
		target_name.set_text(player.current_target.name)
		target_viewport.add_child(target_view_model)
		target_view_model.transform.origin = Vector3.ZERO
		target_hull.set_text(str(round(player.current_target.get_hull_percent())))

		if not target_view_container.visible:
			target_view_container.show()
			target_overhead.show()
	else:
		# No target selected
		target_details_minimal.hide()
		target_icon.hide()
		edge_target_icon.hide()
		target_view_container.hide()
		target_overhead.hide()


func _on_player_throttle_changed():
	var line_pos: Vector2 = Vector2(0, throttle_bar.rect_size.y) + player.throttle * throttle_bar.rect_size.y * Vector2.UP
	line_pos.y = min(line_pos.y, throttle_bar.rect_size.y - 1)
	throttle_line.set_position(line_pos)


func _on_player_began_warp_out():
	hide()
	set_process(false)


func _on_mission_ready():
	camera = get_node(camera_path)
	player = get_node(player_path)

	var overhead_icon = player.get_overhead_icon()
	if overhead_icon != null:
		player_overhead.set_overhead_icon(overhead_icon)

	player_hull_bar.set_max(player.hull_hitpoints)
	player_hull_bar.set_value(player.hull_hitpoints)

	player.connect("cam_changed", self, "_on_player_cam_changed")
	player.connect("power_distribution_changed", self, "_on_player_power_distribution_changed")
	player.connect("shield_boost_changed", self, "_on_player_shield_boost_changed")
	player.connect("target_changed", self, "_on_player_target_changed")
	player.connect("began_warp_out", self, "_on_player_began_warp_out")

	player.connect("damaged", self, "_on_player_damaged")
	player.connect("destroyed", self, "_on_player_destroyed")
	player.connect("warped_out", self, "_on_player_destroyed")

	for index in range(player.QUADRANT_COUNT):
		player.shields[index].connect("hitpoints_changed", self, "_on_player_shield_changed", [ index ])

	_on_player_throttle_changed()
	player.connect("throttle_changed", self, "_on_player_throttle_changed")
	player.connect("energy_weapon_changed", self, "_on_player_energy_weapon_changed")
	player.connect("missile_weapon_changed", self, "_on_player_missile_weapon_changed")

	power_container.set_power_bars(player.power_distribution)

	# Add radar icons
	for node in mission_controller.get_targets(true):
		if node != mission_controller.player:
			var icon = RADAR_ICON.instance()
			icon.set_target(node)
			# Set icon color based on alignment
			var alignment = mission_controller.get_alignment(player.faction, node.faction)
			if alignment != -1:
				icon.set_modulate(ALIGNMENT_COLORS_FADED[alignment])
			else:
				icon.set_modulate(Color.white)

			radar_icons_container.add_child(icon)

	# Set up weapons display based on player loadout
	energy_hardpoint_count = player.energy_weapon_hardpoints.size()
	for index in range(energy_weapon_rows.size()):
		if index < energy_hardpoint_count:
			energy_weapon_rows[index].show()
			energy_weapon_rows[index].set_name(player.energy_weapon_hardpoints[index].weapon_data.get("weapon_name", "none"))
		else:
			energy_weapon_rows[index].hide()

		energy_weapon_rows[index].toggle_arrow(index == 0)

	missile_hardpoint_count = player.missile_weapon_hardpoints.size()
	for index in range(missile_weapon_rows.size()):
		if index < missile_hardpoint_count:
			missile_weapon_rows[index].show()
			missile_weapon_rows[index].set_capacity(player.missile_weapon_hardpoints[index].ammo_capacity)
			missile_weapon_rows[index].set_name(player.missile_weapon_hardpoints[index].weapon_data.get("weapon_name", "none"))
			player.missile_weapon_hardpoints[index].connect("ammo_count_changed", self, "_on_player_ammo_count_changed", [ index ])
		else:
			missile_weapon_rows[index].hide()

		missile_weapon_rows[index].toggle_arrow(index == 0)

	if not player.has_target:
		target_details_minimal.hide()

	for index in range(mission_controller.mission_data.objectives.size()):
		for objective in mission_controller.mission_data.objectives[index]:
			var objective_label = OBJECTIVE_LABEL.instance()
			objective_label.set_text(objective.name)
			objectives_rows.add_child(objective_label)
			if not objective.enabled:
				objective_label.hide()
				objective.connect("triggered", objective_label, "_on_objective_triggered")

			objective.connect("completed", objective_label, "_on_objective_completed")
			objective.connect("failed", objective_label, "_on_objective_failed")

	# Run this once so that everything looks right at the prompt overlay
	_process(0)
	set_process(true)


func _on_target_damaged():
	var hull_percent = max(0, player.current_target.get_hull_percent())
	target_details_minimal.set_hull(hull_percent)
	target_hull.set_text(str(round(hull_percent)))


func _on_target_destroyed(target):
	_disconnect_target_signals(target)
	target_icon.hide()
	edge_target_icon.hide()
	target_view_container.hide()
	target_overhead.hide()
	target_details_minimal.hide()


func _on_target_shield_changed(percent: float, quadrant: int):
	target_details_minimal.set_shield_alpha(quadrant, percent)
	target_overhead.set_shield_alpha(quadrant, percent)


func _process(delta):
	# Update radar icons
	var viewport_rect: Rect2 = viewport.get_visible_rect()
	var radar_position
	for icon in radar_icons_container.get_children():
		if icon.has_target and icon.target_warped_in:
			var target_dist_sq = (icon.target.transform.origin - player.transform.origin).length_squared()
			if icon.target == player.current_target or target_dist_sq < RADAR_RANGE_SQ:
				if not icon.visible:
					icon.show()

				var to_target = (icon.target.transform.origin - player.transform.origin).normalized()
				var unprojected = Vector2(to_target.dot(player.transform.basis.x), -to_target.dot(player.transform.basis.y))

				# Get the radius at this angle so we can project onto the ellipse properly
				var theta = unprojected.angle_to(Vector2.RIGHT)
				var radius = radar.rect_size.x / 2 * radar.rect_size.y / 2 / sqrt(pow(radar.rect_size.x / 2, 2) * pow(sin(theta), 2) + pow(radar.rect_size.y / 2, 2) * pow(cos(theta), 2))

				var center_distance = unprojected.length()
				unprojected = unprojected.normalized() * radius

				if camera.is_position_behind(icon.target.transform.origin):
					radar_position = unprojected - (unprojected * center_distance / 2)
				else:
					radar_position = unprojected * center_distance / 2

				icon.set_position(radar.rect_size / 2 + radar_position)
			elif icon.visible:
				icon.hide()

	# Update target view
	if player.has_target:
		var to_target = player.current_target.transform.origin - player.transform.origin
		var cam_target_dist = (player.current_target.transform.origin - camera.transform.origin).length()
		var icon_pos: Vector2 = camera.unproject_position(player.current_target.transform.origin)
		# Multiply all units by 10 to get meters
		var target_dist = 10 * to_target.length()

		if camera.is_position_in_view(player.current_target.transform.origin):
			if not target_icon.visible:
				target_icon.show()

			var max_pos = Vector2.ZERO
			var min_pos = viewport_rect.size
			for vertex in player.current_target.get_bounding_box():
				var vertex_size = camera.unproject_position(vertex) - icon_pos
				if vertex_size.x > max_pos.x:
					max_pos.x = vertex_size.x
				if vertex_size.y > max_pos.y:
					max_pos.y = vertex_size.y

				if vertex_size.x < min_pos.x:
					min_pos.x = vertex_size.x
				if vertex_size.y < min_pos.y:
					min_pos.y = vertex_size.y

			var bounding_box = Rect2(min_pos, max_pos - min_pos)
			target_icon.update_icon(icon_pos, bounding_box, target_dist)

			if edge_target_icon.visible:
				edge_target_icon.hide()
		else:
			if target_icon.visible:
				target_icon.hide()

			if not edge_target_icon.visible:
				edge_target_icon.show()
			_update_edge_icon()

		target_view_cam.transform.origin = -2 * to_target.normalized()
		target_view_cam.look_at(Vector3.ZERO, player.transform.basis.y)

		target_view_model.set_rotation(player.current_target.rotation)

		target_distance.set_text(str(round(target_dist)))
		target_speed.set_text(str(round(10 * player.current_target.linear_velocity.length())))
	else:
		if target_icon.visible:
			target_icon.hide()

	_update_speed_indicator()

	# Toggle in-range indicator
	if player.is_a_target_in_range():
		if not in_range_icon.visible:
			in_range_icon.show()
	else:
		if in_range_icon.visible:
			in_range_icon.hide()

	weapon_battery_bar.set_value(100 * player.get_weapon_battery_percent())

	# Move target reticule to more accurate position
	if player.cam_mode != player.COCKPIT:
		var reticule_pos_3: Vector3 = player.get_targeting_endpoint()
		target_reticule.set_position(camera.unproject_position(reticule_pos_3))
		var reticule_half_pos_3: Vector3 = player.transform.origin + (reticule_pos_3 - player.transform.origin) / 2
		target_reticule_outer.set_position(camera.unproject_position(reticule_half_pos_3))


func _update_edge_icon():
	var viewport_rect: Rect2 = viewport.get_visible_rect()
	var to_target = (player.current_target.transform.origin - player.transform.origin).normalized()
	var unprojected = (viewport_rect.size / 2) + (Vector2(to_target.dot(player.transform.basis.x), -to_target.dot(player.transform.basis.y)) * max(viewport_rect.size.x, viewport_rect.size.y))

	var icon_pos = MathHelper.get_line_rect_intersect(viewport_rect.size / 2, unprojected, viewport_rect)
	if not icon_pos:
		icon_pos = Vector2.ZERO

	edge_target_icon.set_position(icon_pos)

	var direction = -1
	if icon_pos.x == 0:
		if icon_pos.y == 0:
			direction = EdgeTargetIcon.UP_LEFT
		elif icon_pos.y == viewport_rect.size.y:
			direction = EdgeTargetIcon.DOWN_LEFT
		else:
			direction = EdgeTargetIcon.LEFT
	elif icon_pos.x == viewport_rect.size.x:
		if icon_pos.y == 0:
			direction = EdgeTargetIcon.UP_RIGHT
		elif icon_pos.y == viewport_rect.size.y:
			direction = EdgeTargetIcon.DOWN_RIGHT
		else:
			direction = EdgeTargetIcon.RIGHT
	elif icon_pos.y == 0:
		direction = EdgeTargetIcon.UP
	elif icon_pos.y == viewport_rect.size.y:
		direction = EdgeTargetIcon.DOWN

	edge_target_icon.set_direction(direction)

	var angle_to = (-player.transform.basis.z).angle_to(player.current_target.transform.origin - player.transform.origin)
	edge_target_icon.update_angle_label(angle_to)


func _update_speed_indicator():
	var speed = player.linear_velocity.length()
	var speed_percent = 100 * speed / player.get_max_speed()

	if throttle_bar.value != speed_percent:
		throttle_bar.set_value(speed_percent)

		# Multiply all units by 10 to get meters
		speed_indicator.set_text(str(round(10 * speed)))
		var indicator_pos = Vector2(speed_indicator.rect_position.x, throttle_bar.rect_size.y - (speed_indicator.rect_size.y / 2) - (throttle_bar.value / throttle_bar.max_value) * throttle_bar.rect_size.y)
		speed_indicator.set_position(indicator_pos)


const EdgeTargetIcon = preload("EdgeTargetIcon.gd")
const MathHelper = preload("MathHelper.gd")
const ShipIcon = preload("ShipIcon.gd")

const ALIGNMENT_COLORS: Array = [ Color(1.0, 1.0, 0.0, 1.0), Color(0.25, 1.0, 0.25, 1.0), Color(1.0, 0.25, 0.25, 1.0) ]
const ALIGNMENT_COLORS_FADED: Array = [ Color(1.0, 1.0, 0.0, 0.5), Color(0.25, 1.0, 0.25, 0.5), Color(1.0, 0.25, 0.25, 0.5) ]
const OBJECTIVE_LABEL = preload("res://icons/objective_label.tscn")
const RADAR_ICON = preload("res://icons/radar_icon.tscn")
const RADAR_RANGE_SQ: float = 300.0 * 300.0
const THROTTLE_BAR_SPEED: float = 2.5
