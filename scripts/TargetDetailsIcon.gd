extends CenterContainer

onready var hull_percent_label = get_node("Hull Percent")
onready var shield_icons: Array = [
	get_node("Shield Front"),
	get_node("Shield Rear"),
	get_node("Shield Left"),
	get_node("Shield Right")
]


func set_hull(hull_percent: float):
	hull_percent_label.set_text(str(round(hull_percent)))


func set_shield_alpha(quadrant: int, percent: float):
	var current_color = shield_icons[quadrant].modulate
	current_color.a = percent
	shield_icons[quadrant].set_modulate(current_color)
