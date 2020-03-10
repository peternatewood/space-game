extends Control

onready var clear_binding_checkbox = get_node("Options Rows/TabContainer/Controls/Binding Options/Clear Binding")
onready var color_picker_dialog = get_node("ColorPicker Popup")
onready var color_pickers: Array = [
	get_node("Options Rows/TabContainer/Accessibility/Accessibility Grid/Neutral Color Picker"),
	get_node("Options Rows/TabContainer/Accessibility/Accessibility Grid/Friendly Color Picker"),
	get_node("Options Rows/TabContainer/Accessibility/Accessibility Grid/Hostile Color Picker")
]
onready var colorblindness_options = get_node("Options Rows/TabContainer/Accessibility/Accessibility Grid/Colorblindness Options")
onready var controls_tabs = get_node("Options Rows/TabContainer/Controls/Controls Tabs")
onready var edit_binding_checkbox = get_node("Options Rows/TabContainer/Controls/Binding Options/Edit Checkbox")
onready var go_to_conflict_checkbox = get_node("Options Rows/TabContainer/Controls/Binding Options/Go to Conflict")
onready var hud_color_options = get_node("Options Rows/TabContainer/HUD/Color Options Row/HUD Color Options")
onready var hud_colorpicker = get_node("ColorPicker Popup/HUD ColorPicker")
onready var interactive_hud = get_node("Options Rows/TabContainer/HUD/HUD Panel/Interactive HUD")
onready var keybind_popup = get_node("Keybind Popup")
onready var keybind_accept_button = get_node("Keybind Popup/Popup Rows/Popup Buttons/Accept Button")
onready var keybind_cancel_button = get_node("Keybind Popup/Popup Rows/Popup Buttons/Cancel Button")
onready var keybind_popup_key_label = get_node("Keybind Popup/Popup Rows/Keybind Name Label")
onready var popup_backdrop = get_node("Popup Backdrop")
onready var reflections_popup = get_node("Reflections Popup")
onready var resolution_options = get_node("Options Rows/TabContainer/Video/Resolution Options")
onready var resolution_x_spinbox = get_node("Options Rows/TabContainer/Video/Custom Res Container/Res X SpinBox")
onready var resolution_y_spinbox = get_node("Options Rows/TabContainer/Video/Custom Res Container/Res Y SpinBox")
onready var shadows_atlas_popup = get_node("Shadows Atlas Settings")
onready var shadows_dir_spinbox = get_node("Shadows Atlas Settings/Shadows Atlas Rows/Shadow Spinboxes Container/Directional Shadows SpinBox")
onready var shadows_point_spinbox = get_node("Shadows Atlas Settings/Shadows Atlas Rows/Shadow Spinboxes Container/Point Light Shadows SpinBox")

var editing_keybind: Dictionary = { "input_type": -1 }
var keybinds: Array = []


func _ready():
	var back_button = get_node("Options Rows/First Row/Back Button")
	back_button.connect("pressed", self, "_on_back_button_pressed")

	var viewport = get_viewport()
	var screen_size = OS.get_screen_size()

	# Video
	var fullscreen_checkbox = get_node("Options Rows/TabContainer/Video/Window Options Container/Fullscreen CheckBox")
	fullscreen_checkbox.connect("toggled", self, "_on_fullscreen_checkbox_toggled")

	var borderless_checkbox = get_node("Options Rows/TabContainer/Video/Window Options Container/Borderless CheckBox")
	borderless_checkbox.connect("toggled", self, "_on_borderless_checkbox_toggled")

	resolution_options.connect("item_selected", self, "_on_resolution_options_item_selected")

	var min_res_x: int = screen_size.x
	var min_res_y: int = screen_size.y
	var res = GlobalSettings.get_resolution()
	# Get resolution options and disable any bigger than the current screen size
	for index in range(GlobalSettings.RESOLUTIONS.size()):
		var res_label = str(GlobalSettings.RESOLUTIONS[index].x) + " x " + str(GlobalSettings.RESOLUTIONS[index].y)
		resolution_options.add_item(res_label, index)

		if GlobalSettings.RESOLUTIONS[index].x > screen_size.x or GlobalSettings.RESOLUTIONS[index].y > screen_size.y:
			resolution_options.set_item_disabled(index, true)

		if GlobalSettings.RESOLUTIONS[index].x < min_res_x:
			min_res_x = GlobalSettings.RESOLUTIONS[index].x
		if GlobalSettings.RESOLUTIONS[index].y < min_res_y:
			min_res_y = GlobalSettings.RESOLUTIONS[index].y

	_update_resolution_options_control(res)

	resolution_x_spinbox.set_min(min_res_x)
	resolution_y_spinbox.set_min(min_res_y)
	_set_resolution_spinboxes_max()

	resolution_x_spinbox.set_value(res.x)
	resolution_y_spinbox.set_value(res.y)

	var resolution_button = get_node("Options Rows/TabContainer/Video/Custom Res Container/Res Button")
	resolution_button.connect("pressed", self, "_on_resolution_button_pressed")

	var aa_options = get_node("Options Rows/TabContainer/Video/Two Columns/AA Options")
	aa_options.select(GlobalSettings.get_msaa())
	aa_options.connect("item_selected", self, "_on_aa_options_item_selected")

	shadows_dir_spinbox.set_value(GlobalSettings.get_shadows_dir_atlas_size())
	shadows_point_spinbox.set_value(GlobalSettings.get_shadows_point_atlas_size())

	var shadow_quality_index: int = 0
	if shadows_dir_spinbox.value == shadows_point_spinbox.value:
		for index in range(GlobalSettings.SHADOW_QUALITY.size()):
			if shadows_dir_spinbox.value == GlobalSettings.SHADOW_QUALITY[index]:
				# We have to add one since the first option item is "Custom"
				shadow_quality_index = index + 1
				break

	var shadow_quality_options = get_node("Options Rows/TabContainer/Video/Three Columns/Shadow Quality Options")
	shadow_quality_options.select(shadow_quality_index)
	shadow_quality_options.connect("item_selected", self, "_on_shadow_quality_options_item_selected")

	var hdr_checkbox = get_node("Options Rows/TabContainer/Video/HDR CheckBox")
	hdr_checkbox.set_pressed(GlobalSettings.get_hdr())
	hdr_checkbox.connect("toggled", self, "_on_hdr_checkbox_toggled")

	var vsync_checkbox = get_node("Options Rows/TabContainer/Video/Vsync CheckBox")
	vsync_checkbox.set_pressed(GlobalSettings.get_vsync())
	vsync_checkbox.connect("toggled", self, "_on_vsync_checkbox_toggled")

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

	var fov_slider = get_node("Options Rows/TabContainer/Video/FOV Container/FOV Slider")
	fov_slider.set_value(GlobalSettings.get_fov())
	fov_slider.connect("value_changed", self, "_on_fov_changed")

	# Audio
	var master_mute = get_node("Options Rows/TabContainer/Audio/Master Mute")
	var music_mute = get_node("Options Rows/TabContainer/Audio/Music Mute")
	var sound_effects_mute = get_node("Options Rows/TabContainer/Audio/Sound Effects Mute")
	var ui_sounds_mute = get_node("Options Rows/TabContainer/Audio/UI Sounds Mute")

	master_mute.set_pressed(GlobalSettings.get_audio_mute(GlobalSettings.MASTER))
	master_mute.connect("toggled", self, "_on_mute_toggled", [ GlobalSettings.MASTER ])
	music_mute.set_pressed(GlobalSettings.get_audio_mute(GlobalSettings.MUSIC))
	music_mute.connect("toggled", self, "_on_mute_toggled", [ GlobalSettings.MUSIC ])
	sound_effects_mute.set_pressed(GlobalSettings.get_audio_mute(GlobalSettings.SOUND_EFFECTS))
	sound_effects_mute.connect("toggled", self, "_on_mute_toggled", [ GlobalSettings.SOUND_EFFECTS ])
	ui_sounds_mute.set_pressed(GlobalSettings.get_audio_mute(GlobalSettings.UI_SOUNDS))
	ui_sounds_mute.connect("toggled", self, "_on_mute_toggled", [ GlobalSettings.UI_SOUNDS ])

	var master_audio_slider = get_node("Options Rows/TabContainer/Audio/Master Audio Slider")
	var music_audio_slider = get_node("Options Rows/TabContainer/Audio/Music Audio Slider")
	var sound_effects_audio_slider = get_node("Options Rows/TabContainer/Audio/Sound Effects Audio Slider")
	var ui_sounds_audio_slider = get_node("Options Rows/TabContainer/Audio/UI Sounds Audio Slider")

	master_audio_slider.set_value(GlobalSettings.get_audio_percent(GlobalSettings.MASTER))
	master_audio_slider.connect("value_changed", self, "_on_audio_slider_changed", [ GlobalSettings.MASTER ])
	music_audio_slider.set_value(GlobalSettings.get_audio_percent(GlobalSettings.MUSIC))
	music_audio_slider.connect("value_changed", self, "_on_audio_slider_changed", [ GlobalSettings.MUSIC ])
	sound_effects_audio_slider.set_value(GlobalSettings.get_audio_percent(GlobalSettings.SOUND_EFFECTS))
	sound_effects_audio_slider.connect("value_changed", self, "_on_audio_slider_changed", [ GlobalSettings.SOUND_EFFECTS ])
	ui_sounds_audio_slider.set_value(GlobalSettings.get_audio_percent(GlobalSettings.UI_SOUNDS))
	ui_sounds_audio_slider.connect("value_changed", self, "_on_audio_slider_changed", [ GlobalSettings.UI_SOUNDS ])

	# Controls
	keybind_popup.connect("about_to_show", self, "show_popup_backdrop")
	keybind_popup.connect("popup_hide", self, "hide_popup_backdrop")

	keybind_accept_button.connect("pressed", self, "_on_keybind_popup_accept_pressed")
	keybind_cancel_button.connect("pressed", self, "_on_keybind_popup_cancel_pressed")

	# Loop through all Keybind controls and connect signal
	for keybind_tab in get_node("Options Rows/TabContainer/Controls/Controls Tabs").get_children():
		for container in keybind_tab.get_children():
			if container is ScrollContainer:
				for node in container.get_node("Controls Grid").get_children():
					if node is Keybind:
						node.load_from_simplified_events(GlobalSettings.keybinds[node.action])
						# TODO: Check for conflicts
						for keybind in keybinds:
							for event in node.events:
								if keybind.conflicts_with(node.action, event):
									node.toggle_conflict(true, event)
									keybind.toggle_conflict(true, event)
									break

						node.connect("keybind_button_pressed", self, "_on_keybind_button_pressed")
						node.connect("keybind_changed", GlobalSettings, "_on_keybind_changed")
						keybinds.append(node)

	# Game
	var units_options = get_node("Options Rows/TabContainer/Game/Units Container/Units Options")
	units_options.connect("item_selected", self, "_on_units_options_item_selected")

	# Accessibility
	var dyslexia_checkbox = get_node("Options Rows/TabContainer/Accessibility/Dyslexia Checkbox")
	dyslexia_checkbox.set_pressed(GlobalSettings.get_dyslexia())
	dyslexia_checkbox.connect("toggled", self, "_on_dyslexia_checkbox_toggled")

	toggle_dyslexia(GlobalSettings.get_dyslexia())
	GlobalSettings.connect("dyslexia_toggled", self, "toggle_dyslexia")

	colorblindness_options.select(GlobalSettings.get_colorblindness())
	colorblindness_options.connect("item_selected", self, "_on_colorblindness_selected")

	for index in range(color_pickers.size()):
		color_pickers[index].connect("color_changed", self, "_on_color_picker_changed", [ index ])

	update_color_pickers()

	# HUD
	hud_color_options.select(GlobalSettings.get_hud_palette_index())
	hud_color_options.connect("item_selected", self, "_on_hud_color_options_selected")

	interactive_hud.connect("colorable_node_clicked", self, "_on_interactive_hud_colorable_node_clicked")
	color_picker_dialog.connect("confirmed", self, "_on_color_picker_dialog_confirmed")
	color_picker_dialog.connect("popup_hide", self, "_on_color_picker_dialog_popup_hide")
	hud_colorpicker.connect("color_changed", self, "_on_hud_colorpicker_changed")


func _handle_keybind_popup_input(event):
	var is_valid_input: bool = false

	match editing_keybind.get("input_type", -1):
		Keybind.KEY_ONE, Keybind.KEY_TWO:
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
	GlobalSettings.set_msaa(item_index)


func _on_audio_slider_changed(percent: float, bus_index: int):
	GlobalSettings.set_audio_percent(bus_index, percent)


func _on_back_button_pressed():
	emit_signal("back_button_pressed")


func _on_borderless_checkbox_toggled(button_pressed: bool):
	GlobalSettings.set_borderless_window(button_pressed)


func _on_color_picker_changed(new_color: Color, type_index: int):
	if colorblindness_options.get_selected_id() != GlobalSettings.Colorblindness.CUSTOM:
		colorblindness_options.select(GlobalSettings.Colorblindness.CUSTOM)

	GlobalSettings.set_custom_ui_color(type_index, new_color)


func _on_color_picker_dialog_confirmed():
	var new_color: Color = hud_colorpicker.get_pick_color()
	interactive_hud.set_current_icon_color(new_color)


func _on_color_picker_dialog_popup_hide():
	var previous_color = GlobalSettings.get_hud_custom_color(interactive_hud.current_node_path)
	interactive_hud.set_current_icon_color(previous_color)


func _on_colorblindness_selected(item_index: int):
	GlobalSettings.set_colorblindness(item_index)
	update_color_pickers()


func _on_dyslexia_checkbox_toggled(button_pressed: bool):
	GlobalSettings.set_dyslexia(button_pressed)


func _on_fov_changed(value: float):
	GlobalSettings.set_fov(int(value))


func _on_fullscreen_checkbox_toggled(button_pressed: bool):
	GlobalSettings.set_fullscreen(button_pressed)


func _on_hdr_checkbox_toggled(button_pressed: bool):
	GlobalSettings.set_hdr(button_pressed)


func _on_hud_color_options_selected(item_index: int):
	GlobalSettings.set_hud_palette(item_index)
	interactive_hud.set_palette(GlobalSettings.get_hud_palette())


func _on_hud_colorpicker_changed(new_color: Color):
	interactive_hud.set_current_icon_color(new_color, false)


func _on_interactive_hud_colorable_node_clicked(node):
	var viewport_size = get_viewport().get_visible_rect().size

	var popup_size: Vector2 = color_picker_dialog.get_size()
	var popup_left: float

	if node.get_global_position().x < viewport_size.x / 2:
		popup_left = viewport_size.x - popup_size.x
	else:
		popup_left = 0

	var popup_position = Rect2(popup_left, viewport_size.y / 2 - popup_size.y / 2, popup_size.x, popup_size.y)

	hud_colorpicker.set_pick_color(node.modulate)
	color_picker_dialog.set_text(node.name)
	color_picker_dialog.popup(popup_position)


func _on_keybind_button_pressed(keybind, event, input_type, button):
	if edit_binding_checkbox.pressed:
		editing_keybind["keybind"] = keybind
		editing_keybind["current_event"] = event
		editing_keybind["input_type"] = input_type

		keybind_popup_key_label.set_text(button.text)
		keybind_popup.popup_centered()
		# Probably a function of the popup: this button is focused when we popup(), which is no good for mouse binding
		keybind_accept_button.release_focus()
	elif clear_binding_checkbox.pressed:
		keybind.clear_keybind(input_type)

		for keybind in keybinds:
			keybind.toggle_conflict(false, event)
	elif go_to_conflict_checkbox.pressed:
		# Find the first conflicting action
		for control in keybinds:
			if control.conflicts_with(keybind.action, event):
				# Change to this control's tab
				var tabs = controls_tabs.get_children()
				for index in range(tabs.size()):
					if tabs[index].find_node(control.name):
						controls_tabs.set_current_tab(index)
						# Scroll to the control's position
						for node in tabs[index].get_children():
							if node is ScrollContainer:
								node.set_v_scroll(control.rect_position.y)
								break
						# Control's tab found
						break
				# Conflicting control found
				break


func _on_keybind_popup_accept_pressed():
	if editing_keybind.has("new_event") and editing_keybind.get("new_event") != editing_keybind.get("current_event"):
		editing_keybind["keybind"].update_keybind(editing_keybind["input_type"], editing_keybind["new_event"])

		var new_keybind_conflicts: bool = false
		for keybind in keybinds:
			if keybind.conflicts_with(editing_keybind["keybind"].action, editing_keybind["new_event"]):
				keybind.toggle_conflict(true, editing_keybind["new_event"])
				new_keybind_conflicts = true
			elif keybind.conflicts_with(editing_keybind["keybind"].action, editing_keybind["current_event"]):
				keybind.toggle_conflict(false, editing_keybind["current_event"])

		editing_keybind["keybind"].toggle_conflict(new_keybind_conflicts, editing_keybind["new_event"])

	editing_keybind = { "input_type": -1 }
	keybind_popup.hide()


func _on_keybind_popup_cancel_pressed():
	keybind_popup.hide()


func _on_mute_toggled(button_pressed: bool, bus_index: int):
	GlobalSettings.set_audio_mute(bus_index, button_pressed)


func _on_reflections_accept_pressed():
	# TODO: update reflections GlobalSettings
	reflections_popup.hide()


func _on_reflections_button_pressed():
	reflections_popup.popup_centered()


func _on_reflections_cancel_pressed():
	reflections_popup.hide()


func _on_resolution_button_pressed():
	var resolution = _set_resolution(Vector2(resolution_x_spinbox.value, resolution_y_spinbox.value))
	_update_resolution_options_control(resolution)


func _on_resolution_options_item_selected(res_index: int):
	# We have to subtract one from the index, since the first element is "Custom"
	_set_resolution(GlobalSettings.RESOLUTIONS[res_index - 1])


func _on_shadow_atlas_accept_pressed():
	GlobalSettings.set_shadows_dir_atlas_size(shadows_dir_spinbox.value)
	GlobalSettings.set_shadows_point_atlas_size(shadows_point_spinbox.value)
	shadows_atlas_popup.hide()


func _on_shadows_atlas_button_pressed():
	shadows_atlas_popup.popup_centered()


func _on_shadow_atlas_cancel_pressed():
	shadows_atlas_popup.hide()


func _on_shadow_quality_options_item_selected(item_index: int):
	if item_index != 0:
		var atlas_size = GlobalSettings.SHADOW_QUALITY[item_index - 1]
		GlobalSettings.set_shadows_dir_atlas_size(atlas_size)
		GlobalSettings.set_shadows_point_atlas_size(atlas_size)

		# Update popup spinboxes
		shadows_dir_spinbox.set_value(GlobalSettings.get_shadows_dir_atlas_size())
		shadows_point_spinbox.set_value(GlobalSettings.get_shadows_point_atlas_size())


func _on_units_options_item_selected(item_index: int):
	GlobalSettings.set_units(item_index)


func _on_vsync_checkbox_toggled(button_pressed: bool):
	GlobalSettings.set_vsync(button_pressed)


func _set_resolution(size: Vector2):
	var new_res = GlobalSettings.set_resolution(size)
	resolution_x_spinbox.set_value(new_res.x)
	resolution_y_spinbox.set_value(new_res.y)

	return new_res


func _set_resolution_spinboxes_max():
	var screen_size = OS.get_screen_size()
	resolution_x_spinbox.set_max(screen_size.x)
	resolution_y_spinbox.set_max(screen_size.y)


func _update_resolution_options_control(res: Vector2):
	var new_res_index = -1
	for index in range(GlobalSettings.RESOLUTIONS.size()):
		if GlobalSettings.RESOLUTIONS[index] == res:
			new_res_index = index
			break

	# We have to add one since the first element is not represented in the RESOLUTIONS array
	resolution_options.select(new_res_index + 1)


# PUBLIC


func hide_popup_backdrop():
	popup_backdrop.hide()


func show_popup_backdrop():
	popup_backdrop.show()


func toggle_dyslexia(toggle_on: bool):
	if toggle_on:
		set_theme(GlobalSettings.OPEN_DYSLEXIC_INTERFACE_THEME)
	else:
		set_theme(GlobalSettings.INCONSOLATA_INTERFACE_THEME)


func update_color_pickers():
	var colorblindness_option = GlobalSettings.get_colorblindness()

	if colorblindness_option == GlobalSettings.Colorblindness.CUSTOM:
		# Use custom options
		for index in range(color_pickers.size()):
			color_pickers[index].set_pick_color(GlobalSettings.get_custom_ui_color(index))
	else:
		for index in range(color_pickers.size()):
			color_pickers[index].set_pick_color(GlobalSettings.INTERFACE_COLORS[colorblindness_option][index])


signal back_button_pressed

const Keybind = preload("Keybind.gd")
