extends Control

onready var current_icon = get_node("Current Icon")
onready var highlight_control = get_node("Highlight")
onready var radial_container = get_node("Radial Container")


func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	current_icon.set_modulate(RadialIcon.NORMAL_COLOR)
	current_icon.connect("gui_input", self, "_on_current_icon_gui_input")


func _on_current_icon_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		radial_container.popup_centered()


func _on_mouse_entered():
	current_icon.set_modulate(Color.white)


func _on_mouse_exited():
	current_icon.set_modulate(RadialIcon.NORMAL_COLOR)


# PUBLIC


func hide_current_icon():
	current_icon.set_texture(null)


func set_current_icon(image_resource):
	current_icon.set_texture(image_resource)


const RadialIcon = preload("RadialIcon.gd")

const HALF_RADIUS: float = 106.0
const RADIAL_ICON = preload("res://prefabs/radial_icon.tscn")
