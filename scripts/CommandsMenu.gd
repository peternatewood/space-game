extends PanelContainer

enum { NONE, ALL_SHIPS, WINGS, SHIP }

onready var root_menu = get_node("Root Commands")
onready var ship_commands = get_node("Ship Commands")
onready var ships_menu = get_node("Ships List")
onready var wings_menu = get_node("Wings List")

var command_type: int = NONE


func _input(event):
	if event.is_action("toggle_communcations_menu") and event.pressed:
		if visible:
			hide()
		else:
			show()
