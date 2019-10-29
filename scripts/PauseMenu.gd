extends Control

onready var options_menu = get_node("Options Menu")


func _ready():
	var resume_button = get_node("PanelContainer/Buttons Container/Resume Button")
	resume_button.connect("pressed", self, "_on_resume_button_pressed")

	var options_button = get_node("PanelContainer/Buttons Container/Options Button")
	options_button.connect("pressed", self, "_on_options_button_pressed")

	var quit_menu_button = get_node("PanelContainer/Buttons Container/Quit to Main Menu Button")
	quit_menu_button.connect("pressed", self, "_on_quit_menu_button_pressed")

	var quit_desktop_button = get_node("PanelContainer/Buttons Container/Quit to Desktop Button")
	quit_desktop_button.connect("pressed", self, "_on_quit_desktop_button_pressed")

	options_menu.connect("back_button_pressed", self, "_on_options_back_pressed")


func _on_options_back_pressed():
	options_menu.hide()


func _on_resume_button_pressed():
	hide()
	get_tree().set_pause(false)


func _on_options_button_pressed():
	options_menu.show()


func _on_quit_menu_button_pressed():
	pass


func _on_quit_desktop_button_pressed():
	pass
