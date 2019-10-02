extends Control

export (NodePath) var camera_path
export (NodePath) var enemies_container_path
export (NodePath) var player_icon_path
export (NodePath) var player_path
export (NodePath) var shield_front_path
export (NodePath) var shield_left_path
export (NodePath) var shield_rear_path
export (NodePath) var shield_right_path

onready var debug = get_node("Debug")
onready var edge_target_icon = get_node("Edge Target Icon")
onready var loader = get_node("/root/SceneLoader")
onready var player_icon = get_node(player_icon_path)
onready var player_hull_bar = get_node("Hull Bar")
onready var radar = get_node("Radar")
onready var shield_front = get_node(shield_front_path)
onready var shield_left = get_node(shield_left_path)
onready var shield_rear = get_node(shield_rear_path)
onready var shield_right = get_node(shield_right_path)
onready var target_icon = get_node("Target Icon")
onready var viewport = get_viewport()

var camera
var player
var radar_icons: Array

func _ready():
	loader.connect("scene_loaded", self, "_on_scene_loaded")
	set_process(false)


func _is_position_in_view(pos: Vector3):
	if camera.is_position_behind(pos):
		return false

	return viewport.get_visible_rect().has_point(camera.unproject_position(pos))


func _on_player_damaged():
	player_hull_bar.set_value(player.hitpoints)


func _on_scene_loaded():
	camera = get_node(camera_path)
	player = get_node(player_path)

	var overhead_icon = player.get_overhead_icon()
	if overhead_icon != null:
		player_icon.set_texture(overhead_icon)

	player_hull_bar.set_max(player.hitpoints)
	player_hull_bar.set_value(player.hitpoints)
	player.connect("damaged", self, "_on_player_damaged")

	for node in get_node(enemies_container_path).get_children():
		var icon = RADAR_ICON.instance()
		radar.add_child(icon)
		radar_icons.append({ "target": node, "icon": icon })

	set_process(true)


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
	for icon in radar_icons:
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

		icon.icon.set_position(radar.rect_size / 2 + radar_position)


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


const EdgeTargetIcon = preload("EdgeTargetIcon.gd")
const MathHelper = preload("MathHelper.gd")

const RADAR_ICON = preload("res://icons/enemy_icon.tscn")
