extends Control

onready var arrow_up = get_node("Arrow Up")
onready var arrow_down = get_node("Arrow Down")
onready var arrow_left = get_node("Arrow Left")
onready var arrow_right = get_node("Arrow Right")

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


enum { UP, DOWN, LEFT, RIGHT }
