extends Control

onready var main_menu_popup = get_node("Menu Quit Popup")
onready var options_menu = get_node("Options Menu")
onready var quit_to_desktop_popup = get_node("Desktop Quit Popup")


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
	main_menu_popup.connect("confirmed", self, "_on_main_menu_confirmed")
	quit_to_desktop_popup.connect("confirmed", self, "_on_quit_to_desktop_confirmed")


func _on_main_menu_confirmed():
	emit_signal("main_menu_confirmed")


func _on_options_back_pressed():
	options_menu.hide()


func _on_options_button_pressed():
	options_menu.show()


func _on_resume_button_pressed():
	hide()
	get_tree().set_pause(false)


func _on_quit_menu_button_pressed():
	main_menu_popup.popup_centered()


func _on_quit_desktop_button_pressed():
	quit_to_desktop_popup.popup_centered()


func _on_quit_to_desktop_confirmed():
	get_tree().quit()


signal main_menu_confirmed
