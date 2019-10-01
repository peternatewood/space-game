extends Control

onready var arrow_icons: Array = [
	get_node("Arrow Up"),
	get_node("Arrow Up Right"),
	get_node("Arrow Right"),
	get_node("Arrow Down Right"),
	get_node("Arrow Down"),
	get_node("Arrow Down Left"),
	get_node("Arrow Left"),
	get_node("Arrow Up Left")
]

var arrow_labels: Array = []
var direction: int = 0


func _ready():
	for icon in arrow_icons:
		arrow_labels.append(icon.get_node("Label"))


# PUBLIC


func set_direction(dir: int):
	if direction != dir:
		direction = dir

		var index: int = 0
		for icon in arrow_icons:
			if index == direction:
				icon.show()
			else:
				icon.hide()

			index += 1


# Angle is in radians
func update_angle_label(angle: float):
	var angle_str = str(round(360 * angle / TAU))
	arrow_labels[direction].set_text(angle_str)


enum { UP, UP_RIGHT, RIGHT, DOWN_RIGHT, DOWN, DOWN_LEFT, LEFT, UP_LEFT }
