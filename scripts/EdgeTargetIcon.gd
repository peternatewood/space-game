extends Control

onready var arrow_up = get_node("Arrow Up")
onready var arrow_down = get_node("Arrow Down")
onready var arrow_left = get_node("Arrow Left")
onready var arrow_right = get_node("Arrow Right")
onready var arrow_up_label = get_node("Arrow Up/Label")
onready var arrow_down_label = get_node("Arrow Down/Label")
onready var arrow_left_label = get_node("Arrow Left/Label")
onready var arrow_right_label = get_node("Arrow Right/Label")

var direction: int = 0


# PUBLIC


func set_direction(dir: int):
	if direction != dir:
		direction = dir

		match direction:
			UP:
				arrow_up.show()
				arrow_down.hide()
				arrow_left.hide()
				arrow_right.hide()
			DOWN:
				arrow_up.hide()
				arrow_down.show()
				arrow_left.hide()
				arrow_right.hide()
			LEFT:
				arrow_up.hide()
				arrow_down.hide()
				arrow_left.show()
				arrow_right.hide()
			RIGHT:
				arrow_up.hide()
				arrow_down.hide()
				arrow_left.hide()
				arrow_right.show()


# Angle is in radians
func update_angle_label(angle: float):
	var angle_str = str(round(360 * angle / TAU))

	match direction:
		UP:
			arrow_up_label.set_text(angle_str)
		DOWN:
			arrow_down_label.set_text(angle_str)
		LEFT:
			arrow_left_label.set_text(angle_str)
		RIGHT:
			arrow_right_label.set_text(angle_str)


enum { UP, DOWN, LEFT, RIGHT }
