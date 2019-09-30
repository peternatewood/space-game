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


func _get_edge_direction(pos: Vector2):
	var viewport_size = viewport.get_visible_rect().size

	if pos.x == 0:
		return EdgeTargetIcon.LEFT
	elif pos.x == viewport_size.x:
		return EdgeTargetIcon.RIGHT
	elif pos.y == 0:
		return EdgeTargetIcon.UP
	elif pos.y == viewport_size.y:
		return EdgeTargetIcon.DOWN

	return -1


func _get_edge_pos(pos: Vector3):
	var viewport_rect: Rect2 = viewport.get_visible_rect()
	var unprojected: Vector2 = camera.unproject_position(pos)

	# If the position is behind the camera, unproject_position mirrors the actual position
	if camera.is_position_behind(pos):
		if viewport_rect.has_point(unprojected):
			unprojected = viewport_rect.size / 2 + max(viewport_rect.size.x, viewport_rect.size.y) * (unprojected - viewport_rect.size / 2).normalized()

		var x_pos = viewport_rect.size.x - clamp(unprojected.x, 0, viewport_rect.size.x)
		var y_pos = viewport_rect.size.y - clamp(unprojected.y, 0, viewport_rect.size.y)

		return Vector2(x_pos, y_pos)

	return Vector2(clamp(unprojected.x, 0, viewport_rect.size.x), clamp(unprojected.y, 0, viewport_rect.size.y))


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
			var edge_pos = _get_edge_pos(player.current_target.transform.origin)
			debug.set_text(str(edge_pos))
			edge_target_icon.set_position(edge_pos)

			var edge_direction = _get_edge_direction(edge_pos)
			edge_target_icon.set_direction(edge_direction)

	elif target_icon.visible:
		target_icon.hide()


const EdgeTargetIcon = preload("EdgeTargetIcon.gd")
