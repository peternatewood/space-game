extends Control

onready var overhead_icon = get_node("Overhead Icon")
onready var shield_icons: Array = [
	get_node("Shield Front"),
	get_node("Shield Rear"),
	get_node("Shield Left"),
	get_node("Shield Right")
]


func set_overhead_icon(icon):
	overhead_icon.set_texture(icon)


func set_shield_alpha(direction, alpha):
	var current_color = shield_icons[direction].modulate
	current_color.a = alpha
	shield_icons[direction].set_modulate(current_color)


enum { FRONT, REAR, LEFT, RIGHT }