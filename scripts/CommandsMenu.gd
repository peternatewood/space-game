extends PanelContainer

enum { NONE, ALL_SHIPS, WING, SHIP }

onready var menus_container = get_node("Menus Container")
onready var root_menu = get_node("Root Commands")

var command_type: int = NONE
var reinforcements_list
var ship_commands
var ship_name: String
var ships_menu
var timeout_countdown: float = 0.0
var wing: int = -1
var wings_menu


func _ready():
	ship_commands = menus_container.get_node("Ship Commands")
	ships_menu = menus_container.get_node("Ships List")
	reinforcements_list = menus_container.get_node("Reinforcements List")
	wings_menu = menus_container.get_node("Wings List")


func _handle_number_press(number: int):
	# Handle number press based on current menu
	if root_menu.visible:
		match number:
			1:
				command_type = ALL_SHIPS
				ship_commands.show()
			2:
				command_type = WING
				wings_menu.show()
			3:
				command_type = SHIP
				# TODO: populate ships list here?
				ships_menu.show()
			4:
				reinforcements_list.show()
			_:
				# Not a valid number, so we do nothing
				return

		root_menu.hide()
		menus_container.show()
	elif wings_menu.visible:
		wing = number
		wings_menu.hide()
		ship_commands.show()
	elif ships_menu.visible:
		ship_name =  "ship " + str(number)
		ships_menu.hide()
		ship_commands.show()
	elif reinforcements_list.visible:
		print("Calling reinforcements: " + str(number))
		hide()
	elif ship_commands.visible:
		match command_type:
			ALL_SHIPS:
				print("All ships: " + str(number))
			WING:
				print("Wing " + str(wing) + ": " + str(number))
			SHIP:
				print(ship_name + ": " + str(number))
			_:
				# Not a valid number, so we do nothing
				return

		hide()

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
			KEY_0, KEY_KP_0:
				if wings_menu.visible:
					menus_container.hide()
					wings_menu.hide()
					root_menu.show()
				elif ships_menu.visible:
					menus_container.hide()
					ships_menu.hide()
					root_menu.show()
				elif reinforcements_list.visible:
					menus_container.hide()
					reinforcements_list.hide()
					root_menu.show()
				elif ship_commands.visible:
					ship_commands.hide()

					match command_type:
						ALL_SHIPS:
							menus_container.hide()
							root_menu.show()
						WING:
							wings_menu.show()
						SHIP:
							ships_menu.show()


func _process(delta):
	if timeout_countdown > 0:
		timeout_countdown -= delta

		if timeout_countdown <= 0:
			hide()


# PUBLIC


func hide():
	root_menu.show()
	menus_container.hide()
	ship_commands.hide()
	ships_menu.hide()
	wings_menu.hide()

	.hide()


var TIMEOUT_DELAY: float = 4.0 # In seconds
