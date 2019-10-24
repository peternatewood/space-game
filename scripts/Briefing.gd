extends Control

onready var briefing_button = get_node("Columns/Menu Buttons/Briefing Button")
onready var briefing_container = get_node("Columns/Menus Container/Briefing Container")
onready var briefing_rows = get_node("Columns/Menus Container/Briefing Container/Briefing Rows")
onready var loader = get_node("/root/SceneLoader")
onready var loadout_button = get_node("Columns/Menu Buttons/Loadout Button")
onready var loadout_container = get_node("Columns/Menus Container/Loadout")
onready var mission_data = get_node("/root/MissionData")
onready var start_button = get_node("Columns/Menus Container/Start Button")


func _ready():
	for brief_copy in mission_data.briefing:
		var brief_label = Label.new()
		brief_label.set_text(brief_copy)
		briefing_rows.add_child(brief_label)

	briefing_button.connect("pressed", self, "_on_briefing_button_pressed")
	loadout_button.connect("pressed", self, "_on_loadout_button_pressed")

	start_button.connect("pressed", self, "_on_start_button_pressed")


func _on_briefing_button_pressed():
	briefing_container.show()
	loadout_container.hide()


func _on_loadout_button_pressed():
	briefing_container.hide()
	loadout_container.show()


func _on_start_button_pressed():
	loader.load_scene(mission_data.mission_scene_path)
