extends Control

enum { KEY, MOUSE, JOY_BUTTON, JOY_AXIS }

export (String) var action = ""

onready var key_one_button = get_node("Key One Button")
onready var key_two_button = get_node("Key Two Button")
onready var mouse_button = get_node("Mouse Button")
onready var joypad_button_button = get_node("Joypad Button")
onready var joypad_axis_button = get_node("Joypad Axis")

var conflicts: Array = []
var events: Array = [ [ null, null ], null, null, null ]
var keybind_conflicts: bool = false
var keybind_type


func _ready():
	var keys_index: int = 0
	for event in InputMap.get_action_list(action):
		if event is InputEventKey:
			if keys_index < 2:
				events[KEY][keys_index] = event
				keys_index += 1
		elif event is InputEventMouseButton:
			events[MOUSE] = event
		elif event is InputEventJoypadButton:
			events[JOY_BUTTON] = event
		elif event is InputEventJoypadMotion:
			events[JOY_AXIS] = event

	key_one_button.set_text(event_to_text(events[KEY][0]))
	key_two_button.set_text(event_to_text(events[KEY][1]))
	mouse_button.set_text(event_to_text(events[MOUSE]))
	joypad_button_button.set_text(event_to_text(events[JOY_BUTTON]))
	joypad_axis_button.set_text(event_to_text(events[JOY_AXIS]))

	key_one_button.connect("pressed", self, "_on_key_one_button_pressed")
	key_two_button.connect("pressed", self, "_on_key_two_button_pressed")
	mouse_button.connect("pressed", self, "_on_mouse_button_pressed")
	joypad_button_button.connect("pressed", self, "_on_joypad_button_button_pressed")
	joypad_axis_button.connect("pressed", self, "_on_joypad_axis_button_pressed")


func _on_key_one_button_pressed():
	emit_signal("keybind_button_pressed", self, events[KEY][0], KEY, key_one_button, 0)


func _on_key_two_button_pressed():
	emit_signal("keybind_button_pressed", self, events[KEY][1], KEY, key_two_button, 1)


func _on_mouse_button_pressed():
	emit_signal("keybind_button_pressed", self, events[MOUSE], MOUSE, mouse_button)


func _on_joypad_button_button_pressed():
	emit_signal("keybind_button_pressed", self, events[JOY_BUTTON], JOY_BUTTON, joypad_button_button)


func _on_joypad_axis_button_pressed():
	emit_signal("keybind_button_pressed", self, events[JOY_AXIS], JOY_AXIS, joypad_axis_button)


# PUBLIC


func clear_keybind(input_type: int, button_index: int = -1):
	if input_type == KEY:
		if events[KEY][button_index] != null:
			InputMap.action_erase_event(action, events[KEY][button_index])

			if button_index == 0:
				key_one_button.set_text("none")
			elif button_index == 1:
				key_two_button.set_text("none")
	else:
		if events[input_type] != null:
			InputMap.action_erase_event(action, events[input_type])

			match input_type:
				MOUSE:
					mouse_button.set_text("none")
				JOY_BUTTON:
					joypad_button_button.set_text("none")
				JOY_AXIS:
					joypad_axis_button.set_text("none")

	emit_signal("keybind_changed", action)


func conflicts_with(other_action: String, event):
	if action == other_action:
		return false

	if event is InputEventKey:
		for index in range(2):
			if events[KEY][index] != null:
				if do_key_events_match(events[KEY][index], event):
					return true
	else:
		if event is InputEventMouseButton:
			return events[MOUSE].button_index == event.button_index
		elif event is InputEventJoypadButton:
			return events[JOY_BUTTON].button_index == event.button_index
		elif event is InputEventJoypadMotion:
			var axis_direction = 1 if events[JOY_AXIS].axis_value > 0 else -1
			var other_axis_direction = 1 if event.axis_value > 0 else -1

			return events[JOY_AXIS].axis == event.axis and axis_direction == other_axis_direction

	return false


func load_from_simplified_events(simplified_events: Dictionary):
	for key in simplified_events.keys():
		var new_event

		match key:
			"key_one":
				new_event = InputEventKey.new()
				new_event.set_pressed(true)
				new_event.set_scancode(simplified_events[key].scancode)
				new_event.set_alt(simplified_events[key].alt)
				new_event.set_command(simplified_events[key].command)
				new_event.set_control(simplified_events[key].control)
				new_event.set_metakey(simplified_events[key].meta)
				new_event.set_shift(simplified_events[key].shift)

				update_keybind(KEY, new_event, 0)
			"key_two":
				new_event = InputEventKey.new()
				new_event.set_pressed(true)
				new_event.set_scancode(simplified_events[key].scancode)
				new_event.set_alt(simplified_events[key].alt)
				new_event.set_command(simplified_events[key].command)
				new_event.set_control(simplified_events[key].control)
				new_event.set_metakey(simplified_events[key].meta)
				new_event.set_shift(simplified_events[key].shift)

				update_keybind(KEY, new_event, 1)
			"mouse_button":
				new_event = InputEventMouseButton.new()
				new_event.set_pressed(true)
				new_event.set_button_index(simplified_events[key].button_index)

				update_keybind(MOUSE, new_event)
			"joypad_button":
				new_event = InputEventJoypadButton.new()
				new_event.set_pressed(true)
				new_event.set_button_index(simplified_events[key].button_index)

				update_keybind(JOY_BUTTON, new_event)
			"joypad_axis":
				new_event = InputEventJoypadMotion.new()
				new_event.set_axis(simplified_events[key].axis)
				new_event.set_axis_value(simplified_events[key].axis_direction)

				update_keybind(JOY_AXIS, new_event)


func toggle_conflict(toggle_on: bool, event):
	if toggle_on != keybind_conflicts:
		keybind_conflicts = toggle_on
		var new_theme = KEYBIND_CONFLICT_THEME if toggle_on else null

		if event is InputEventKey:
			if events[KEY][0] != null and do_key_events_match(events[KEY][0], event):
				key_one_button.set_theme(new_theme)
			elif events[KEY][1] != null and do_key_events_match(events[KEY][1], event):
				key_two_button.set_theme(new_theme)
		elif event is InputEventMouseButton:
			mouse_button.set_theme(new_theme)
		elif event is InputEventJoypadButton:
			joypad_button_button.set_theme(new_theme)
		elif event is InputEventJoypadMotion:
			joypad_axis_button.set_theme(new_theme)


func update_keybind(input_type: int, new_event, button_index: int = -1):
	var is_valid_update: bool = false

	match input_type:
		KEY:
			if new_event is InputEventKey and new_event.pressed and button_index != -1 and button_index < 2:
				is_valid_update = true
				if button_index == 0:
					key_one_button.set_text(event_to_text(new_event))
				elif button_index == 1:
					key_two_button.set_text(event_to_text(new_event))
		MOUSE:
			if new_event is InputEventMouseButton and new_event.pressed:
				is_valid_update = true
				mouse_button.set_text(event_to_text(new_event))
		JOY_BUTTON:
			if new_event is InputEventJoypadButton and new_event.pressed:
				is_valid_update = true
				joypad_button_button.set_text(event_to_text(new_event))
		JOY_AXIS:
			if new_event is InputEventJoypadMotion:
				is_valid_update = true
				joypad_axis_button.set_text(event_to_text(new_event))

	if is_valid_update:
		if input_type == KEY:
			if events[KEY][button_index] != null:
				InputMap.action_erase_event(action, events[KEY][button_index])

			events[KEY][button_index] = new_event
		else:
			if events[input_type] != null:
				InputMap.action_erase_event(action, events[input_type])

			events[input_type] = new_event

		InputMap.action_add_event(action, new_event)
		emit_signal("keybind_changed", action)
	else:
		print("Invalid keybind update: " + var2str(new_event))


static func action_to_simplified_events(action: String):
	var events: Dictionary = {}

	var keys_index: int = 0
	for event in InputMap.get_action_list(action):
		if event is InputEventKey:
			if keys_index == 0:
				events["key_one"] = { "scancode": event.scancode, "alt": event.alt, "command": event.command, "control": event.control, "meta": event.meta, "shift": event.shift }
			elif keys_index == 1:
				events["key_two"] = { "scancode": event.scancode, "alt": event.alt, "command": event.command, "control": event.control, "meta": event.meta, "shift": event.shift }
			keys_index += 11
		elif event is InputEventMouseButton:
			events["mouse_button"] = { "button_index": event.button_index }
		elif event is InputEventJoypadButton:
			events["joypad_button"] = { "button_index": event.button_index }
		elif event is InputEventJoypadMotion:
			var axis_direction = 1 if event.axis_value < 0 else 0
			events["joypad_axis"] = { "axis": event.axis, "axis_direction": axis_direction }

	return events


static func do_key_events_match(event_a: InputEventKey, event_b: InputEventKey):
	return event_a.scancode == event_b.scancode and event_a.alt == event_b.alt and event_a.shift == event_b.shift and event_a.control == event_b.control and event_a.meta == event_b.meta and event_a.command == event_b.command


static func event_to_text(event = null):
	if event == null:
		return "none"
	elif event is InputEventMouseButton:
		match event.button_index:
			BUTTON_LEFT:
				return "Left Button"
			BUTTON_RIGHT:
				return "Right Button"
			BUTTON_MIDDLE:
				return "Middle Button"
			BUTTON_XBUTTON1:
				return "Extra Button 1"
			BUTTON_XBUTTON2:
				return "Extra Button 2"
			BUTTON_WHEEL_UP:
				return "Wheel Up"
			BUTTON_WHEEL_DOWN:
				return "Wheel Down"
			BUTTON_WHEEL_LEFT:
				return "Wheel Left"
			BUTTON_WHEEL_RIGHT:
				return "Wheel Right"
	elif event is InputEventJoypadMotion:
		match event.axis:
			JOY_AXIS_0:
				var axis_direction = "Left" if event.axis_value < 0 else "Right"
				return "Left Stick " + axis_direction
			JOY_AXIS_1:
				var axis_direction = "Up" if event.axis_value < 0 else "Down"
				return "Left Stick " + axis_direction
			JOY_AXIS_2:
				var axis_direction = "Left" if event.axis_value < 0 else "Right"
				return "Right Stick " + axis_direction
			JOY_AXIS_3:
				var axis_direction = "Up" if event.axis_value < 0 else "Down"
				return "Right Stick " + axis_direction
			JOY_AXIS_4:
				var axis_direction = "-" if event.axis_value < 0 else "+"
				return "Axis 4 " + axis_direction
			JOY_AXIS_5:
				var axis_direction = "-" if event.axis_value < 0 else "+"
				return "Axis 5 " + axis_direction
			JOY_AXIS_6:
				return "Left Trigger"
			JOY_AXIS_7:
				return "Right Trigger"
			JOY_AXIS_8:
				var axis_direction = "-" if event.axis_value < 0 else "+"
				return "Axis 8 " + axis_direction
			JOY_AXIS_9:
				var axis_direction = "-" if event.axis_value < 0 else "+"
				return "Axis 9 " + axis_direction

	return event.as_text()


signal keybind_button_pressed
signal keybind_changed

const KEYBIND_CONFLICT_THEME = preload("res://themes/keybind_conflict.tres")
