extends Control

onready var delete_profile_dialog = get_node("Delete Profile Dialog")
onready var loader = get_node("/root/SceneLoader")
onready var new_profile_dialog = get_node("New Profile Dialog")
onready var new_profile_lineedit = get_node("New Profile Dialog/New Profile LineEdit")
onready var profile_rows = get_node("Profiles Container/Profiles Panel/Profiles Scroll/Profile Rows")
onready var profiles_data = get_node("/root/ProfilesData")

var profile_to_delete: String


func _ready():
	delete_profile_dialog.connect("confirmed", self, "_on_delete_profile_confirmed")
	new_profile_dialog.connect("confirmed", self, "_on_new_profile_confirmed")

	var new_profile_button = get_node("Profiles Container/Profile Options/New Profile Button")
	new_profile_button.connect("pressed", new_profile_dialog, "popup_centered")

	for profile_name in profiles_data.profile_section_map.keys():
		add_profile_buttons(profile_name)


func _on_delete_profile_confirmed():
	for profile_button in profile_rows.get_children():
		if profile_button.is_name(profile_to_delete):
			profiles_data.delete_profile(profile_to_delete)
			profile_button.queue_free()
			break

	profile_to_delete = ""


func _on_new_profile_confirmed():
	add_profile_buttons(new_profile_lineedit.text)

	profiles_data.create_profile(new_profile_lineedit.text)


func _on_profile_delete_pressed(profile_name: String):
	profile_to_delete = profile_name
	delete_profile_dialog.set_text("Delete " + profile_name + "'s profile?")
	delete_profile_dialog.popup_centered()


func _on_profile_name_pressed(profile_name: String):
	if profiles_data.load_profile(profile_name):
		loader.load_scene("res://title.tscn")
	else:
		print("Unable to load profile: " + profile_name)


# PUBLIC


func add_profile_buttons(profile_name: String):
	var profile_buttons_instance = PROFILE_BUTTONS.instance()
	profile_rows.add_child(profile_buttons_instance)
	profile_buttons_instance.set_profile(profile_name)

	profile_buttons_instance.connect("delete_pressed", self, "_on_profile_delete_pressed")
	profile_buttons_instance.connect("name_pressed", self, "_on_profile_name_pressed")


const PROFILE_BUTTONS = preload("res://prefabs/profile_buttons.tscn")
