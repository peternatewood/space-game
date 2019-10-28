extends Control

onready var directional_shadow_spinbox = get_node("Shadows Atlas Settings/Shadows Atlas Rows/Directional Shadows Container/Directional Shadows SpinBox")
onready var keybind_popup = get_node("Keybind Popup")
onready var keybind_accept_button = get_node("Keybind Popup/Popup Rows/Popup Buttons/Accept Button")
onready var keybind_cancel_button = get_node("Keybind Popup/Popup Rows/Popup Buttons/Cancel Button")
onready var keybind_popup_key_label = get_node("Keybind Popup/Popup Rows/Keybind Name Label")
onready var point_light_shadow_spinbox = get_node("Shadows Atlas Settings/Shadows Atlas Rows/Point Light Shadows Container2/Point Light Shadows SpinBox")
onready var popup_backdrop = get_node("Popup Backdrop")
onready var shadows_atlas_popup = get_node("Shadows Atlas Settings")

var editing_keybind: Dictionary = { "input_type": -1 }


func _ready():
	var back_button = get_node("Options Rows/First Row/Back Button")
	back_button.connect("pressed", self, "_on_back_button_pressed")

	var shadows_atlas_button = get_node("Options Rows/TabContainer/Video/Three Columns/Shadows Atlas Button")
	shadows_atlas_button.connect("pressed", self, "_on_shadows_atlas_button_pressed")

	shadows_atlas_popup.connect("about_to_show", self, "show_popup_backdrop")
	shadows_atlas_popup.connect("popup_hide", self, "hide_popup_backdrop")

	var shadow_atlas_accept = get_node("Shadows Atlas Settings/Shadows Atlas Rows/Shadows Atlas Buttons/Shadows Atlas Accept")
	var shadow_atlas_cancel = get_node("Shadows Atlas Settings/Shadows Atlas Rows/Shadows Atlas Buttons/Shadows Atlas Cancel")
	shadow_atlas_accept.connect("pressed", self, "_on_shadow_atlas_accept_pressed")
	shadow_atlas_cancel.connect("pressed", self, "_on_shadow_atlas_cancel_pressed")

	keybind_popup.connect("about_to_show", self, "show_popup_backdrop")
	keybind_popup.connect("popup_hide", self, "hide_popup_backdrop")

	keybind_accept_button.connect("pressed", self, "_on_keybind_popup_accept_pressed")
	keybind_cancel_button.connect("pressed", self, "_on_keybind_popup_cancel_pressed")

	for keybind_node in get_node("Options Rows/TabContainer/Controls/Control Rows").get_children():
		keybind_node.connect("keybind_button_pressed", self, "_on_keybind_button_pressed")


func _handle_keybind_popup_input(event):
	var is_valid_input: bool = false

	match editing_keybind.get("input_type", -1):
		Keybind.KEY:
			if event is InputEventKey and event.pressed:
				is_valid_input = true
		Keybind.MOUSE:
			if event is InputEventMouseButton and event.pressed:
				is_valid_input = true
		Keybind.JOY_BUTTON:
			if event is InputEventJoypadButton and event.pressed:
				is_valid_input = true
		Keybind.JOY_AXIS:
			if event is InputEventJoypadMotion:
				is_valid_input = true

	if is_valid_input:
		editing_keybind["new_event"] = event
		keybind_popup_key_label.set_text(Keybind.event_to_text(event))


func _input(event):
	if keybind_popup.visible:
		if not event is InputEventMouseButton or (not keybind_accept_button.is_hovered() and not keybind_cancel_button.is_hovered()):
			_handle_keybind_popup_input(event)


func _on_back_button_pressed():
	emit_signal("back_button_pressed")


func _on_keybind_button_pressed(keybind, event, input_type, button, button_index: int = -1):
	editing_keybind["keybind"] = keybind
	editing_keybind["current_event"] = event
	editing_keybind["input_type"] = input_type
	editing_keybind["button_index"] = button_index

	keybind_popup_key_label.set_text(button.text)
	keybind_popup.popup()
	# Probably a function of the popup: this button is focused when we popup(), which is no good for mouse binding
	keybind_accept_button.release_focus()


func _on_keybind_popup_accept_pressed():
	if editing_keybind.has("new_event") and editing_keybind.get("new_event") != editing_keybind.get("current_event"):
		editing_keybind["keybind"].update_keybind(editing_keybind["input_type"], editing_keybind["new_event"], editing_keybind.get("button_index", -1))

	editing_keybind = { "input_type": -1 }
	keybind_popup.hide()


func _on_keybind_popup_cancel_pressed():
	keybind_popup.hide()


func _on_shadow_atlas_accept_pressed():
	# TODO: update shadow atlas settings
	shadows_atlas_popup.hide()


func _on_shadows_atlas_button_pressed():
	shadows_atlas_popup.popup()


func _on_shadow_atlas_cancel_pressed():
	shadows_atlas_popup.hide()


# PUBLIC


func hide_popup_backdrop():
	popup_backdrop.hide()


func show_popup_backdrop():
	popup_backdrop.show()


signal back_button_pressed

const Keybind = preload("Keybind.gd")
