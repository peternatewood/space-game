extends Control

export (NodePath) var camera_path
export (NodePath) var player_path

onready var camera = get_node(camera_path)
onready var edge_target_icon = get_node("Edge Target Icon")
onready var player = get_node(player_path)
onready var target_icon = get_node("Target Icon")
onready var viewport = get_viewport()


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


func _get_edge_pos(pos: Vector3):
	var viewport_size: Vector2 = viewport.get_visible_rect().size
	var unprojected: Vector2 = camera.unproject_position(pos)

	# If the position is directly behind, the camera will unproject it back into the viewport
	if camera.is_position_behind(pos):
		var x_pos: float
		var y_pos: float
		var x_percent: float = abs(viewport_size.x / 2 - unprojected.x) / viewport_size.x
		var y_percent: float = abs(viewport_size.y / 2 - unprojected.y) / viewport_size.y

		if x_percent > y_percent:
			x_pos = 0 if x_pos < 0 else viewport_size.x
			y_pos = clamp(unprojected.y, 0, viewport_size.y)
		else:
			x_pos = clamp(unprojected.x, 0, viewport_size.x)
			y_pos = 0 if y_pos < 0 else viewport_size.y

		return Vector2(x_pos, y_pos)

	return Vector2(clamp(unprojected.x, 0, viewport_size.x), clamp(unprojected.y, 0, viewport_size.y))


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
			edge_target_icon.set_position(edge_pos)
			var edge_direction = _get_edge_direction(edge_pos)
			edge_target_icon.set_direction(edge_direction)
	elif target_icon.visible:
		target_icon.hide()


const EdgeTargetIcon = preload("EdgeTargetIcon.gd")
