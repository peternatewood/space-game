extends Control

onready var bottom_left = get_node("Bottom Left")
onready var bottom_right = get_node("Bottom Right")
onready var top_left = get_node("Top Left")
onready var top_right = get_node("Top Right")


func set_icon_size(icon_size: Vector2):
	if icon_size.x < 4:
		icon_size.x = 4
	if icon_size.y < 4:
		icon_size.y = 4

	bottom_left.set_position(Vector2(-icon_size.x, icon_size.y))
	bottom_left.points[0].x = icon_size.x / 2
	bottom_left.points[2].y = icon_size.y / -2

	bottom_right.set_position(icon_size)
	bottom_right.points[0].y = icon_size.y / -2
	bottom_right.points[2].x = icon_size.x / -2

	top_left.set_position(-icon_size)
	top_left.points[0].y = icon_size.y / 2
	top_left.points[2].x = icon_size.x / 2

	top_right.set_position(Vector2(icon_size.x, -icon_size.y))
	top_right.points[0].x = icon_size.x / -2
	top_right.points[2].y = icon_size.y / 2
