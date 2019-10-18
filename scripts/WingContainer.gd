extends Control

onready var icons = get_children()


func toggle(toggle_on: bool):
	if toggle_on:
		show()
	else:
		hide()

	for icon in icons:
		if icon.enabled:
			icon.set_monitoring(toggle_on)
			icon.set_monitorable(toggle_on)
