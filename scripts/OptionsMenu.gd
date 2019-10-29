extends Control

onready var directional_shadow_spinbox = get_node("Shadows Atlas Settings/Shadows Atlas Rows/Directional Shadows Container/Directional Shadows SpinBox")
onready var keybind_popup = get_node("Keybind Popup")
onready var keybind_accept_button = get_node("Keybind Popup/Popup Rows/Popup Buttons/Accept Button")
onready var keybind_cancel_button = get_node("Keybind Popup/Popup Rows/Popup Buttons/Cancel Button")
onready var keybind_popup_key_label = get_node("Keybind Popup/Popup Rows/Keybind Name Label")
onready var point_light_shadow_spinbox = get_node("Shadows Atlas Settings/Shadows Atlas Rows/Point Light Shadows Container2/Point Light Shadows SpinBox")
onready var popup_backdrop = get_node("Popup Backdrop")
onready var reflections_popup = get_node("Reflections Popup")
onready var resolution_options = get_node("Options Rows/TabContainer/Video/Resolution Options")
onready var resolution_x_spinbox = get_node("Options Rows/TabContainer/Video/Custom Res Container/Res X SpinBox")
onready var resolution_y_spinbox = get_node("Options Rows/TabContainer/Video/Custom Res Container/Res Y SpinBox")
onready var settings = get_node("/root/GlobalSettings")
onready var shadows_atlas_popup = get_node("Shadows Atlas Settings")
onready var shadows_dir_spinbox = get_node("Shadows Atlas Settings/Shadows Atlas Rows/Shadow Spinboxes Container/Directional Shadows SpinBox")
onready var shadows_point_spinbox = get_node("Shadows Atlas Settings/Shadows Atlas Rows/Shadow Spinboxes Container/Point Light Shadows SpinBox")

var editing_keybind: Dictionary = { "input_type": -1 }


func _ready():
	var back_button = get_node("Options Rows/First Row/Back Button")
	back_button.connect("pressed", self, "_on_back_button_pressed")

	var viewport = get_viewport()
	var screen_size = OS.get_screen_size()

	var fullscreen_checkbox = get_node("Options Rows/TabContainer/Video/Window Options Container/Fullscreen CheckBox")
	fullscreen_checkbox.connect("toggled", self, "_on_fullscreen_checkbox_toggled")

	var borderless_checkbox = get_node("Options Rows/TabContainer/Video/Window Options Container/Borderless CheckBox")
	borderless_checkbox.connect("toggled", self, "_on_borderless_checkbox_toggled")

	resolution_options.connect("item_selected", self, "_on_resolution_options_item_selected")

	var min_res_x: int = screen_size.x
	var min_res_y: int = screen_size.y
	# Get resolution options and disable any bigger than the current screen size
	for index in range(settings.RESOLUTIONS.size()):
		var res_label = str(settings.RESOLUTIONS[index].x) + " x " + str(settings.RESOLUTIONS[index].y)
		resolution_options.add_item(res_label, index)

		if settings.RESOLUTIONS[index].x > screen_size.x or settings.RESOLUTIONS[index].y > screen_size.y:
			resolution_options.set_item_disabled(index, true)

		if settings.RESOLUTIONS[index].x < min_res_x:
			min_res_x = settings.RESOLUTIONS[index].x
		if settings.RESOLUTIONS[index].y < min_res_y:
			min_res_y = settings.RESOLUTIONS[index].y

	var res = settings.resolution.get_value()
	resolution_x_spinbox.set_value(res.x)
	resolution_y_spinbox.set_value(res.y)
	resolution_x_spinbox.set_min(min_res_x)
	resolution_y_spinbox.set_min(min_res_y)
	_set_resolution_spinboxes_max()

	var resolution_button = get_node("Options Rows/TabContainer/Video/Custom Res Container/Res Button")
	resolution_button.connect("pressed", self, "_on_resolution_button_pressed")

	var aa_options = get_node("Options Rows/TabContainer/Video/Two Columns/AA Options")
	aa_options.select(settings.msaa.get_value())
	aa_options.connect("item_selected", self, "_on_aa_options_item_selected")

	shadows_dir_spinbox.set_value(settings.shadows_dir.get_value())
	shadows_point_spinbox.set_value(settings.shadows_point.get_value())

	var shadow_quality_index: int = 0
	if shadows_dir_spinbox.value == shadows_point_spinbox.value:
		for index in range(settings.SHADOW_QUALITY.size()):
			if shadows_dir_spinbox.value == settings.SHADOW_QUALITY[index]:
				# We have to add one since the first option item is "Custom"
				shadow_quality_index = index + 1
				break

	var shadow_quality_options = get_node("Options Rows/TabContainer/Video/Three Columns/Shadow Quality Options")
	shadow_quality_options.select(shadow_quality_index)
	shadow_quality_options.connect("item_selected", self, "_on_shadow_quality_options_item_selected")

	# Connect popups and their buttons
	var shadows_atlas_button = get_node("Options Rows/TabContainer/Video/Three Columns/Shadows Atlas Button")
	shadows_atlas_button.connect("pressed", self, "_on_shadows_atlas_button_pressed")

	shadows_atlas_popup.connect("about_to_show", self, "show_popup_backdrop")
	shadows_atlas_popup.connect("popup_hide", self, "hide_popup_backdrop")

	var shadow_atlas_accept = get_node("Shadows Atlas Settings/Shadows Atlas Rows/Shadows Atlas Buttons/Shadows Atlas Accept")
	var shadow_atlas_cancel = get_node("Shadows Atlas Settings/Shadows Atlas Rows/Shadows Atlas Buttons/Shadows Atlas Cancel")
	shadow_atlas_accept.connect("pressed", self, "_on_shadow_atlas_accept_pressed")
	shadow_atlas_cancel.connect("pressed", self, "_on_shadow_atlas_cancel_pressed")

	var reflections_button = get_node("Options Rows/TabContainer/Video/Three Columns/Reflections Button")
	reflections_button.connect("pressed", self, "_on_reflections_button_pressed")

	reflections_popup.connect("about_to_show", self, "show_popup_backdrop")
	reflections_popup.connect("popup_hide", self, "hide_popup_backdrop")

	var reflections_accept = get_node("Reflections Popup/Reflections Rows/Reflections Popup Buttons/Reflections Accept")
	var reflections_cancel = get_node("Reflections Popup/Reflections Rows/Reflections Popup Buttons/Reflections Cancel")
	reflections_accept.connect("pressed", self, "_on_reflections_accept_pressed")
	reflections_cancel.connect("pressed", self, "_on_reflections_cancel_pressed")

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


func _on_aa_options_item_selected(item_index: int):
	settings.set_msaa(item_index)


func _on_back_button_pressed():
	emit_signal("back_button_pressed")


func _on_borderless_checkbox_toggled(button_pressed: bool):
	settings.set_borderless_window(button_pressed)


func _on_fullscreen_checkbox_toggled(button_pressed: bool):
	settings.set_fullscreen(button_pressed)


func _on_keybind_button_pressed(keybind, event, input_type, button, button_index: int = -1):
	editing_keybind["keybind"] = keybind
	editing_keybind["current_event"] = event
	editing_keybind["input_type"] = input_type
	editing_keybind["button_index"] = button_index

	keybind_popup_key_label.set_text(button.text)
	keybind_popup.popup_centered()
	# Probably a function of the popup: this button is focused when we popup(), which is no good for mouse binding
	keybind_accept_button.release_focus()


func _on_keybind_popup_accept_pressed():
	if editing_keybind.has("new_event") and editing_keybind.get("new_event") != editing_keybind.get("current_event"):
		editing_keybind["keybind"].update_keybind(editing_keybind["input_type"], editing_keybind["new_event"], editing_keybind.get("button_index", -1))

	editing_keybind = { "input_type": -1 }
	keybind_popup.hide()


func _on_keybind_popup_cancel_pressed():
	keybind_popup.hide()


func _on_reflections_accept_pressed():
	# TODO: update reflections settings
	reflections_popup.hide()


func _on_reflections_button_pressed():
	reflections_popup.popup_centered()


func _on_reflections_cancel_pressed():
	reflections_popup.hide()


func _on_resolution_button_pressed():
	var resolution = _set_resolution(Vector2(resolution_x_spinbox.value, resolution_y_spinbox.value))
	# Update the resolution options control
	var new_res_index = -1
	for index in range(settings.RESOLUTIONS.size()):
		if settings.RESOLUTIONS[index] == resolution:
			new_res_index = index
			break

	# We have to add one since the first element is not represented in the RESOLUTIONS array
	resolution_options.select(new_res_index + 1)


func _on_resolution_options_item_selected(res_index: int):
	# We have to subtract one from the index, since the first element is "Custom"
	_set_resolution(settings.RESOLUTIONS[res_index - 1])


func _on_shadow_atlas_accept_pressed():
	settings.set_shadows_dir_atlas_size(shadows_dir_spinbox.value)
	settings.set_shadows_point_atlas_size(shadows_point_spinbox.value)
	shadows_atlas_popup.hide()


func _on_shadows_atlas_button_pressed():
	shadows_atlas_popup.popup_centered()


func _on_shadow_atlas_cancel_pressed():
	shadows_atlas_popup.hide()


func _on_shadow_quality_options_item_selected(item_index: int):
	if item_index != 0:
		var atlas_size = settings.SHADOW_QUALITY[item_index - 1]
		settings.set_shadows_dir_atlas_size(atlas_size)
		settings.set_shadows_point_atlas_size(atlas_size)

		# Update popup spinboxes
		shadows_dir_spinbox.set_value(settings.shadows_dir.get_value())
		shadows_point_spinbox.set_value(settings.shadows_point.get_value())


func _set_resolution(size: Vector2):
	var new_res = settings.set_resolution(size)
	resolution_x_spinbox.set_value(new_res.x)
	resolution_y_spinbox.set_value(new_res.y)

	return new_res


func _set_resolution_spinboxes_max():
	var screen_size = OS.get_screen_size()
	resolution_x_spinbox.set_max(screen_size.x)
	resolution_y_spinbox.set_max(screen_size.y)

# PUBLIC


func hide_popup_backdrop():
	popup_backdrop.hide()


func show_popup_backdrop():
	popup_backdrop.show()


signal back_button_pressed

const Keybind = preload("Keybind.gd")
