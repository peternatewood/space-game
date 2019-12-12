extends Control

onready var name_button = get_node("Name Button")


func _ready():
	var delete_button = get_node("Delete Button")
	delete_button.connect("pressed", self, "_on_delete_pressed")

	name_button.connect("pressed", self, "_on_name_pressed")


func _on_delete_pressed():
	emit_signal("delete_pressed", name_button.text)


func _on_name_pressed():
	emit_signal("name_pressed", name_button.text)


# PUBLIC


func is_name(profile_name: String):
	return name_button.text == profile_name


func set_profile(profile_name: String):
	name_button.set_text(profile_name)


signal delete_pressed
signal name_pressed
