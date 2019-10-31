extends Control

export (float) var default = 50
export (float) var max_value = 100
export (float) var min_value = 0
export (float) var step = 1

onready var spinbox = get_node("SpinBox")
onready var slider = get_node("Slider")

var _is_mouse_down: bool = false
var _update_other_input: bool = false


func _ready():
	slider.set_max(max_value)
	slider.set_min(min_value)
	slider.set_step(step)
	slider.set_value(default)

	spinbox.set_max(max_value)
	spinbox.set_min(min_value)
	spinbox.set_step(step)
	spinbox.set_value(default)

	slider.connect("gui_input", self, "_on_slider_gui_input")
	slider.connect("value_changed", self, "_on_slider_value_changed")
	spinbox.connect("gui_input", self, "_on_spinbox_gui_input")
	spinbox.connect("value_changed", self, "_on_spinbox_value_changed")


func _on_slider_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		_is_mouse_down = event.pressed
	elif event is InputEventMouseMotion:
		if _is_mouse_down:
			_update_other_input = false
			spinbox.set_value(slider.value)
		else:
			_update_other_input = true


func _on_slider_value_changed(value: float):
	if _update_other_input:
		_update_other_input = false
		spinbox.set_value(value)

	emit_signal("value_changed", value)


func _on_spinbox_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		_update_other_input = true


func _on_spinbox_value_changed(value: float):
	if _update_other_input:
		_update_other_input = false
		slider.set_value(value)


# PUBLIC


func set_value(value):
	slider.set_value(value)
	spinbox.set_value(value)


signal value_changed
