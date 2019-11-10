extends Control

onready var button_hover_sound = get_node("Button Hover")


func _ready():
	for node in get_tree().get_nodes_in_group("audible_hover"):
		node.connect("mouse_entered", button_hover_sound, "play")
