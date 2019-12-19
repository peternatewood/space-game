extends PanelContainer

enum { NONE, ALL_SHIPS, WING, SHIP }

onready var menus_container = get_node("Menus Container")
onready var mission_controller = get_node_or_null("/root/Mission Controller")
onready var root_menu = get_node("Root Commands")

var allow_input: bool = false
var command_type: int = NONE
var commanding_ship
var number_command_map: Array = [
	0, # null
	1, # Attack
	2, # Defend
	3, # Ignore
	8, # Cover Me
	4, # Attack Any
	5  # Depart
]
var menus_enabled: bool = true
var reinforcements_list
var ship_commands
var ships_menu
var timeout_countdown: float = 0.0
var wing
var wings_menu


func _ready():
	ship_commands = menus_container.get_node("Ship Commands")
	ships_menu = menus_container.get_node("Ships List")
	reinforcements_list = menus_container.get_node("Reinforcements List")
	wings_menu = menus_container.get_node("Wings List")

	if mission_controller != null:
		mission_controller.connect("mission_ready", self, "_on_mission_ready")


func _on_commanding_ship_destroyed():
	if command_type == SHIP and ship_commands.visible:
		commanding_ship = null
		hide()


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
		if number > wings_menu.get_child_count():
			# Not a valid number, so we do nothing
			return

		wing = wings_menu.get_child(number - 1)
		if wing.wing_warped_in:
			if wing.wing_destroyed:
				return

			wings_menu.hide()
			ship_commands.show()
	elif ships_menu.visible:
		var ship_index = number - 1
		var ship_labels = ships_menu.get_children()

		if ship_index < ship_labels.size() and ship_labels[ship_index].ship.is_warped_in:
			if commanding_ship != null:
				commanding_ship.disconnect("destroyed", self, "_on_commanding_ship_destroyed")
				commanding_ship.disconnect("warped_out", self, "_on_commanding_ship_destroyed")

			commanding_ship = ship_labels[ship_index].ship
			commanding_ship.connect("destroyed", self, "_on_commanding_ship_destroyed")
			commanding_ship.connect("warped_out", self, "_on_commanding_ship_destroyed")
			ships_menu.hide()
			ship_commands.show()
		# If the number isn't valid, we don't return so the input resets the timeout
	elif reinforcements_list.visible:
		var wing_index = number - 1
		var wing_labels = reinforcements_list.get_children()

		if wing_index < wing_labels.size() and wing_labels[wing_index].enabled:
			for ship in wing_labels[wing_index].wing_ships:
				ship.warp(true)

			# Add wing under wings list
			var arrived_wing = COMMUNICATIONS_LABEL.instance()
			arrived_wing.set_wing(wing_labels[wing_index].wing_name, wing_labels[wing_index].wing_ships, wings_menu.get_child_count() + 1)
			wings_menu.add_child(arrived_wing)

			# Disable now warped-in wing
			wing_labels[wing_index].disable()

			reinforcements_list.hide()
			hide()
		else:
			# Not a valid number, so we do nothing
			return
	elif ship_commands.visible:
		if number >= number_command_map.size():
			# Invalid command number
			return

		var command_index: int = number_command_map[number]

		match command_type:
			ALL_SHIPS:
				for ship in mission_controller.get_commandable_ships():
					ship.set_command(command_index, mission_controller.player)
			WING:
				for ship in wing.wing_ships:
					ship.set_command(command_index, mission_controller.player)
			SHIP:
				commanding_ship.set_command(command_index, mission_controller.player)
				commanding_ship = null
			_:
				# Not a valid number, so we do nothing
				return

		hide()

	timeout_countdown = TIMEOUT_DELAY


func _input(event):
	if allow_input:
		if event.is_action("toggle_communications_menu") and event.pressed:
			if visible:
				hide()
			else:
				show()
				timeout_countdown = TIMEOUT_DELAY
		elif menus_enabled and event is InputEventKey and event.pressed:
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


func _on_mission_ready():
	allow_input = true

	# Build ships list
	var index: int = 1
	var commandable_ships = mission_controller.get_commandable_ships(true)
	for ship in commandable_ships:
		var comm_label = COMMUNICATIONS_LABEL.instance()
		comm_label.set_ship(ship, index)
		ships_menu.add_child(comm_label)
		comm_label.connect("ship_destroyed", self, "_update_ships_list")
		index += 1

	# Build wings list
	var friendly_wings: Array = []
	for ship in commandable_ships:
		if not friendly_wings.has(ship.wing_name):
			friendly_wings.append(ship.wing_name)

	index = 1
	for wing in friendly_wings:
		var wing_ships = mission_controller.get_ships_in_wing(wing, mission_controller.player)

		if wing_ships.size() > 0:
			var alignment = mission_controller.get_alignment(mission_controller.player.faction, wing_ships[0].faction)

			if alignment == mission_controller.FRIENDLY:
				var comm_label = COMMUNICATIONS_LABEL.instance()
				comm_label.set_wing(wing, wing_ships, index)
				wings_menu.add_child(comm_label)
				index += 1

	# Build reinforcements list
	index = 1
	for wing in mission_controller.reinforcement_wings:
		var wing_ships = mission_controller.get_ships_in_wing(wing, mission_controller.player, true)

		if wing_ships.size() > 0:
			var comm_label = COMMUNICATIONS_LABEL.instance()
			comm_label.set_wing(wing, wing_ships, index, true)
			reinforcements_list.add_child(comm_label)
			index += 1

	mission_controller.player.connect("subsystem_destroyed", self, "_on_subsystem_destroyed")


func _on_subsystem_destroyed(subsystem_category: int):
	if subsystem_category == 0:
		toggle_enabled(false)


func _process(delta):
	if timeout_countdown > 0:
		timeout_countdown -= delta

		if timeout_countdown <= 0:
			hide()


func _update_ships_list():
	var index: int = 1
	for label in ships_menu.get_children():
		if not label.ship_destroyed:
			label.set_number(index)
			index += 1


# PUBLIC


func hide():
	root_menu.show()
	menus_container.hide()
	ship_commands.hide()
	ships_menu.hide()
	wings_menu.hide()
	reinforcements_list.hide()

	.hide()


func toggle_enabled(toggle_on: bool):
	menus_enabled = toggle_on

	if toggle_on:
		root_menu.set_modulate(Color.white)
	else:
		root_menu.set_modulate(Color(0.5, 0.5, 0.5))


const COMMUNICATIONS_LABEL = preload("res://icons/communications_label.tscn")
const TIMEOUT_DELAY: float = 4.0 # In seconds
