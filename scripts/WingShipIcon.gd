extends Area2D

export (bool) var enabled = true

onready var cross = get_node("Cross")
onready var mouse_click_control = get_node("Mouse Click Control")
onready var ship_icon = get_node("Ship Icon")


func _ready():
	if enabled:
		mouse_click_control.connect("gui_input", self, "_on_gui_input")
	else:
		disable()


func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		highlight(event.pressed)


# PUBLIC


func disable():
	enabled = false
	cross.show()
	ship_icon.hide()
	set_monitoring(false)
	set_monitorable(false)


func highlight(toggle_on: bool):
	if toggle_on:
		set_modulate(Color.yellow)
	else:
		set_modulate(Color.white)


func set_icon(image_resource):
	ship_icon.set_texture(image_resource)
