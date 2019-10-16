extends PanelContainer

enum { NONE, ALL_SHIPS, WINGS, SHIP }

onready var root_menu = get_node("Root Commands")
onready var ship_commands = get_node("Ship Commands")
onready var ships_menu = get_node("Ships List")
onready var wings_menu = get_node("Wings List")

var command_type: int = NONE
var timeout_countdown: float = 0.0


func _input(event):
	if event.is_action("toggle_communcations_menu") and event.pressed:
		if visible:
			hide()
		else:
			show()
			timeout_countdown = TIMEOUT_DELAY


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
