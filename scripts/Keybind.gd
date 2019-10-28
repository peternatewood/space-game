extends Control

enum { KEY, MOUSE, JOY_BUTTON, JOY_AXIS }

export (String) var action = ""

onready var key_one_button = get_node("Key One Button")
onready var key_two_button = get_node("Key Two Button")
onready var keybind_label = get_node("Keybind Label")
onready var mouse_button = get_node("Mouse Button")
onready var joypad_button_button = get_node("Joypad Button")
onready var joypad_axis_button = get_node("Joypad Axis")

var events: Array = [ [ null, null ], null, null, null ]
var keybind_type


func _ready():
	keybind_label.set_text(name)

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
	emit_signal("keybind_button_pressed", action, events[KEY][0], KEY, key_one_button, 0)


func _on_key_two_button_pressed():
	emit_signal("keybind_button_pressed", self, events[KEY][1], KEY, key_two_button, 1)


func _on_mouse_button_pressed():
	emit_signal("keybind_button_pressed", self, events[MOUSE], MOUSE, mouse_button)


func _on_joypad_button_button_pressed():
	emit_signal("keybind_button_pressed", self, events[JOY_BUTTON], JOY_BUTTON, joypad_button_button)


func _on_joypad_axis_button_pressed():
	emit_signal("keybind_button_pressed", self, events[JOY_AXIS], JOY_AXIS, joypad_axis_button)


# PUBLIC


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

	print(input_type, new_event.as_text(), is_valid_update)

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

	return event.as_text()


signal keybind_button_pressed
