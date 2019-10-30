extends Control

onready var icons = get_children()


func toggle(toggle_on: bool):
	if toggle_on:
		show()
	else:
		hide()
