extends Control

onready var bottom_left = get_node("Bottom Left")
onready var bottom_right = get_node("Bottom Right")
onready var distance_label = get_node("Distance Label")
onready var top_left = get_node("Top Left")
onready var top_right = get_node("Top Right")

var original_box: Rect2


func _ready():
	original_box = Rect2(top_left.get_position(), bottom_right.get_position() - top_left.get_position())


# PUBLIC


func update_icon(pos: Vector2, bounding_box: Rect2, distance: float):
	var true_box = bounding_box if bounding_box.size > original_box.size else original_box

	distance_label.set_text(str(round(distance)))

	bottom_left.set_position(Vector2(true_box.position.x, true_box.end.y))
	bottom_right.set_position(true_box.end)
	distance_label.set_position(DISTANCE_LABEL_OFFSET + Vector2(true_box.position.x - (distance_label.rect_size.x + 4), true_box.position.y - distance_label.rect_size.y / 2))
	top_left.set_position(true_box.position)
	top_right.set_position(Vector2(true_box.end.x, true_box.position.y))

	# Move the endpoints of each line to scale without changing line width
	top_left.points[0].y = true_box.size.y * LINE_ENDING_SCALE
	top_left.points[top_left.points.size() - 1].x = true_box.size.x * LINE_ENDING_SCALE

	top_right.points[0].x = true_box.size.x * -LINE_ENDING_SCALE
	top_right.points[top_right.points.size() - 1].y = true_box.size.y * LINE_ENDING_SCALE

	bottom_left.points[0].x = true_box.size.x * LINE_ENDING_SCALE
	bottom_left.points[bottom_left.points.size() - 1].y = true_box.size.y * -LINE_ENDING_SCALE

	bottom_right.points[0].y = true_box.size.y * -LINE_ENDING_SCALE
	bottom_right.points[bottom_right.points.size() - 1].x = true_box.size.x * -LINE_ENDING_SCALE

	set_position(pos)


const DISTANCE_LABEL_OFFSET: Vector2 = -2 * Vector2.ONE
const LINE_ENDING_SCALE: float = 0.25
