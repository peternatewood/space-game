extends Control

export (NodePath) var camera_path
export (NodePath) var player_path

onready var camera = get_node(camera_path)
onready var debug = get_node("Debug")
onready var edge_target_icon = get_node("Edge Target Icon")
onready var player = get_node(player_path)
onready var target_icon = get_node("Target Icon")
onready var viewport = get_viewport()


func _ready():
	debug.set_text("Hello!")


func _is_position_in_view(pos: Vector3):
	if camera.is_position_behind(pos):
		return false

	return viewport.get_visible_rect().has_point(camera.unproject_position(pos))


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


func _update_edge_icon():
	var viewport_rect: Rect2 = viewport.get_visible_rect()
	var unprojected: Vector2 = camera.unproject_position(player.current_target.transform.origin)

	var edge_pos = Vector2(clamp(unprojected.x, 0, viewport_rect.size.x), clamp(unprojected.y, 0, viewport_rect.size.y))
	# If the position is behind the camera, unproject_position mirrors the actual position
	if camera.is_position_behind(player.current_target.transform.origin):
		if viewport_rect.has_point(unprojected):
			unprojected = viewport_rect.size / 2 + max(viewport_rect.size.x, viewport_rect.size.y) * (unprojected - viewport_rect.size / 2).normalized()

		edge_pos = Vector2(viewport_rect.size.x - clamp(unprojected.x, 0, viewport_rect.size.x), viewport_rect.size.y - clamp(unprojected.y, 0, viewport_rect.size.y))
	else:
		edge_pos = Vector2(clamp(unprojected.x, 0, viewport_rect.size.x), clamp(unprojected.y, 0, viewport_rect.size.y))

	edge_target_icon.set_position(edge_pos)

	if edge_pos.x == 0:
		edge_target_icon.set_direction(EdgeTargetIcon.LEFT)
	elif edge_pos.x == viewport_rect.size.x:
		edge_target_icon.set_direction(EdgeTargetIcon.RIGHT)
	elif edge_pos.y == 0:
		edge_target_icon.set_direction(EdgeTargetIcon.UP)
	elif edge_pos.y == viewport_rect.size.y:
		edge_target_icon.set_direction(EdgeTargetIcon.DOWN)

	var angle_to = (-player.transform.basis.z).angle_to(player.current_target.transform.origin - player.transform.origin)
	edge_target_icon.update_angle_label(angle_to)


const EdgeTargetIcon = preload("EdgeTargetIcon.gd")
