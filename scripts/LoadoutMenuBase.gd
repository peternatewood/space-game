extends Control

onready var border = get_node("Border")
onready var current_icon = get_node("Current Icon")
onready var popup = get_node("Popup")


func _ready():
	current_icon.set_modulate(LoadoutIcon.NORMAL_COLOR)

	current_icon.connect("mouse_entered", self, "_on_mouse_entered")
	current_icon.connect("mouse_exited", self, "_on_mouse_exited")
	current_icon.connect("pressed", self, "_on_current_icon_pressed")


func _on_current_icon_pressed():
	if not popup.visible:
		popup.popup_centered()
		emit_signal("selection_pressed")


func _on_icon_pressed(icon_data: String, image_resource):
	set_current_icon(image_resource)
	popup.hide()
	emit_signal("icon_pressed", icon_data)


func _on_mouse_entered():
	current_icon.set_modulate(Color.white)


func _on_mouse_exited():
	current_icon.set_modulate(LoadoutIcon.NORMAL_COLOR)


# PUBLIC


func hide_current_icon():
	current_icon.set_normal_texture(null)


func set_current_icon(image_resource):
	current_icon.set_normal_texture(image_resource)


func toggle_border(toggle_on: bool):
	if toggle_on:
		border.show()
	else:
		border.hide()


signal icon_pressed
signal selection_pressed

const LoadoutIcon = preload("LoadoutIcon.gd")

const HALF_RADIUS: float = 106.0
const LOADOUT_ICON = preload("res://prefabs/loadout_icon.tscn")
