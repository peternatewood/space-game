extends Control

onready var bottom_left = get_node("Bottom Left")
onready var bottom_right = get_node("Bottom Right")
onready var top_left = get_node("Top Left")
onready var top_right = get_node("Top Right")

var bottom_left_offset
var bottom_right_offset
var original_scale: float
var top_left_offset
var top_right_offset


func _ready():
	bottom_left_offset = bottom_left.get_position()
	bottom_right_offset = bottom_right.get_position()
	top_left_offset = top_left.get_position()
	top_right_offset = top_right.get_position()

	# Keep original scale
	original_scale = top_left.width


# PUBLIC


func update_icon(pos: Vector2, scale: float):
	var true_scale = max(1, scale)
	set_scale(Vector2.ONE * true_scale)

	bottom_left.set_width(original_scale / true_scale)
	bottom_right.set_width(original_scale / true_scale)
	top_left.set_width(original_scale / true_scale)
	top_right.set_width(original_scale / true_scale)

	set_position(pos)
