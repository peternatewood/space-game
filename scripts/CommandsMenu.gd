extends PanelContainer

enum { NONE, ALL_SHIPS, WINGS, SHIP }

onready var root_menu = get_node("Root Commands")
onready var ship_commands = get_node("Ship Commands")
onready var ships_menu = get_node("Ships List")
onready var wings_menu = get_node("Wings List")

var command_type: int = NONE
var timeout_countdown: float = 0.0


func _handle_number_press(number: int):
	print(str(number))
	timeout_countdown = TIMEOUT_DELAY


func _input(event):
	if event.is_action("toggle_communcations_menu") and event.pressed:
		if visible:
			hide()
		else:
			show()
			timeout_countdown = TIMEOUT_DELAY
	elif event is InputEventKey and event.pressed:
		# Handle number inputs
		match event.scancode:
			KEY_1, KEY_KP_1:
				_handle_number_press(1)
			KEY_2, KEY_KP_2:
				_handle_number_press(2)
			KEY_3, KEY_KP_3:
				_handle_number_press(3)
			KEY_4, KEY_KP_4:
				_handle_number_press(4)
			KEY_5, KEY_KP_5:
				_handle_number_press(5)
			KEY_6, KEY_KP_6:
				_handle_number_press(6)
			KEY_7, KEY_KP_7:
				_handle_number_press(7)


func _process(delta):
	if timeout_countdown > 0:
		timeout_countdown -= delta

		if timeout_countdown <= 0:
			hide()
			root_menu.show()
			ship_commands.hide()
			ships_menu.hide()
			wings_menu.hide()


var TIMEOUT_DELAY: float = 4.0 # In seconds
