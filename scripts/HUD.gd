extends Control

export (NodePath) var camera_path
export (NodePath) var enemies_container_path
export (NodePath) var player_path

onready var debug = get_node("Debug")
onready var edge_target_icon = get_node("Edge Target Icon")
onready var loader = get_node("/root/SceneLoader")
onready var player_overhead = get_node("Player Overhead")
onready var player_hull_bar = get_node("Hull Bar")
onready var radar = get_node("Radar")
onready var speed_indicator = get_node("Throttle Bar Container/Speed Indicator")
onready var target_icon = get_node("Target Icon")
onready var target_overhead = get_node("Target Overhead")
onready var target_view_container = get_node("Target View Container")
onready var target_viewport = get_node("Target Viewport")
onready var throttle_bar = get_node("Throttle Bar Container/Throttle Bar")
onready var throttle_line = get_node("Throttle Bar Container/Throttle Line")
onready var viewport = get_viewport()

var camera
var player
var radar_icons_container: Control
var target_view_cam
var target_view_model

func _ready():
	radar_icons_container = radar.get_node("Radar Icons Container")
	target_view_cam = target_viewport.get_node("Camera")
	target_view_model = target_viewport.get_node("Frog Fighter")

	loader.connect("scene_loaded", self, "_on_scene_loaded")
	set_process(false)


func _disconnect_target_signals(target):
	target.disconnect("damaged", self, "_on_target_damaged")
	target.disconnect("destroyed", self, "_on_target_destroyed")

	target.shield_front.disconnect("destroyed", self, "_on_target_shield_front_changed")
	target.shield_left.disconnect("destroyed", self, "_on_target_shield_left_changed")
	target.shield_rear.disconnect("destroyed", self, "_on_target_shield_rear_changed")
	target.shield_right.disconnect("destroyed", self, "_on_target_shield_right_changed")


func _is_position_in_view(pos: Vector3):
	if camera.is_position_behind(pos):
		return false

	return viewport.get_visible_rect().has_point(camera.unproject_position(pos))


func _on_player_damaged():
	player_hull_bar.set_value(player.hitpoints)


func _on_player_destroyed():
	hide()
	set_process(false)


func _on_player_shield_front_changed(percent: float):
	player_overhead.set_shield_alpha(ShipIcon.FRONT, percent)


func _on_player_shield_left_changed(percent: float):
	player_overhead.set_shield_alpha(ShipIcon.LEFT, percent)


func _on_player_shield_rear_changed(percent: float):
	player_overhead.set_shield_alpha(ShipIcon.REAR, percent)


func _on_player_shield_right_changed(percent: float):
	player_overhead.set_shield_alpha(ShipIcon.RIGHT, percent)


func _on_player_target_changed(last_target):
	if player.has_target:
		target_viewport.remove_child(target_view_model)
		var source_filename = player.current_target.get_source_filename()
		if source_filename == null:
			print("Missing source file for " + player.current_target.name)
			return

		var overhead_icon = player.current_target.get_overhead_icon()
		if overhead_icon == null:
			print("Missing overhead icon for " + player.current_target.name)
			return

		# Disconnect signals from old target
		if last_target != null:
			_disconnect_target_signals(last_target)

		player.current_target.connect("damaged", self, "_on_target_damaged")
		player.current_target.connect("destroyed", self, "_on_target_destroyed", [ player.current_target ])

		player.current_target.shield_front.connect("destroyed", self, "_on_target_shield_front_changed")
		player.current_target.shield_left.connect("destroyed", self, "_on_target_shield_left_changed")
		player.current_target.shield_rear.connect("destroyed", self, "_on_target_shield_rear_changed")
		player.current_target.shield_right.connect("destroyed", self, "_on_target_shield_right_changed")

		target_overhead.set_overhead_icon(overhead_icon)
		target_view_model = load(source_filename).instance()
		target_viewport.add_child(target_view_model)


func _on_player_throttle_changed():
	var line_pos: Vector2 = Vector2(0, throttle_bar.rect_size.y) + player.throttle * throttle_bar.rect_size.y * Vector2.UP
	line_pos.y = min(line_pos.y, throttle_bar.rect_size.y - 1)
	throttle_line.set_position(line_pos)


func _on_scene_loaded():
	camera = get_node(camera_path)
	player = get_node(player_path)

	var overhead_icon = player.get_overhead_icon()
	if overhead_icon != null:
		player_overhead.set_overhead_icon(overhead_icon)

	player_hull_bar.set_max(player.hitpoints)
	player_hull_bar.set_value(player.hitpoints)

	player.connect("target_changed", self, "_on_player_target_changed")
	player.connect("damaged", self, "_on_player_damaged")
	player.connect("destroyed", self, "_on_player_destroyed")

	player.shield_front.connect("hitpoints_changed", self, "_on_player_shield_front_changed")
	player.shield_left.connect("hitpoints_changed", self, "_on_player_shield_left_changed")
	player.shield_rear.connect("hitpoints_changed", self, "_on_player_shield_rear_changed")
	player.shield_right.connect("hitpoints_changed", self, "_on_player_shield_right_changed")

	throttle_bar.set_max(player.max_speed)
	_on_player_throttle_changed()
	player.connect("throttle_changed", self, "_on_player_throttle_changed")

	for node in get_node(enemies_container_path).get_children():
		var icon = RADAR_ICON.instance()
		icon.set_target(node)
		radar_icons_container.add_child(icon)

	set_process(true)


func _on_target_damaged():
	pass


func _on_target_destroyed(target):
	_disconnect_target_signals(target)


func _on_target_shield_front_changed(percent: float):
	target_overhead.set_shield_alpha(ShipIcon.FRONT, percent)


func _on_target_shield_left_changed(percent: float):
	target_overhead.set_shield_alpha(ShipIcon.LEFT, percent)


func _on_target_shield_rear_changed(percent: float):
	target_overhead.set_shield_alpha(ShipIcon.REAR, percent)


func _on_target_shield_right_changed(percent: float):
	target_overhead.set_shield_alpha(ShipIcon.RIGHT, percent)



func _process(delta):
	if player.has_target:
		var icon_pos: Vector2 = camera.unproject_position(player.current_target.transform.origin)

		if _is_position_in_view(player.current_target.transform.origin):
			if not target_icon.visible:
				target_icon.show()
			target_icon.set_position(icon_pos)

			if edge_target_icon.visible:
				edge_target_icon.hide()
		else:
			if target_icon.visible:
				target_icon.hide()

			if not edge_target_icon.visible:
				edge_target_icon.show()
			_update_edge_icon()
	elif target_icon.visible:
		target_icon.hide()

	# Update radar icons
	var viewport_rect: Rect2 = viewport.get_visible_rect()
	var radar_position
	for icon in radar_icons_container.get_children():
		if icon.has_target:
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

	# Update target view
	if player.has_target:
		if not target_view_container.visible:
			target_view_container.show()
			target_overhead.show()

		var to_target = player.current_target.transform.origin - player.transform.origin
		target_view_cam.transform.origin = -2 * to_target.normalized()
		target_view_cam.look_at(Vector3.ZERO, player.transform.basis.y)

		target_view_model.set_rotation(player.current_target.rotation)
	elif target_view_container.visible:
		target_view_container.hide()
		target_overhead.hide()

	_update_speed_indicator()


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

	if throttle_bar.value != speed:
		throttle_bar.set_value(speed)

		speed_indicator.set_text(str(round(speed)))
		var indicator_pos = Vector2(speed_indicator.rect_position.x, throttle_bar.rect_size.y - (speed_indicator.rect_size.y / 2) - (throttle_bar.value / throttle_bar.max_value) * throttle_bar.rect_size.y)
		speed_indicator.set_position(indicator_pos)


const EdgeTargetIcon = preload("EdgeTargetIcon.gd")
const MathHelper = preload("MathHelper.gd")
const ShipIcon = preload("ShipIcon.gd")

const RADAR_ICON = preload("res://icons/enemy_icon.tscn")
const THROTTLE_BAR_SPEED: float = 2.5
