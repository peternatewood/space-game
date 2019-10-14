extends Camera


func is_position_in_view(pos: Vector3):
	if is_position_behind(pos):
		return false

	return get_viewport().get_visible_rect().has_point(unproject_position(pos))
