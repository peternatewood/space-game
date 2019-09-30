extends Control

export (NodePath) var camera_path
export (NodePath) var player_path

onready var camera = get_node(camera_path)
onready var player = get_node(player_path)
onready var target_icon = get_node("Target Icon")
onready var viewport = get_viewport()


func _is_position_in_view(pos: Vector3):
	if camera.is_position_behind(pos):
		return false

	return viewport.get_visible_rect().has_point(camera.unproject_position(pos))


func _process(delta):
	var icon_pos: Vector2

	if player.has_target:
		icon_pos = camera.unproject_position(player.current_target.transform.origin)

		if _is_position_in_view(player.current_target.transform.origin):
			if not target_icon.visible:
				target_icon.show()
			target_icon.set_position(icon_pos)
		else:
			if target_icon.visible:
				target_icon.hide()

	elif target_icon.visible:
		target_icon.hide()
