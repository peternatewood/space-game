extends Control

onready var briefing_button = get_node("Columns/Menu Buttons/Briefing Button")
onready var briefing_container = get_node("Columns/Menus Container/Briefing Container")
onready var briefing_rows = get_node("Columns/Menus Container/Briefing Container/Briefing Panel/Briefing Rows")
onready var loadout_button = get_node("Columns/Menu Buttons/Loadout Button")
onready var loadout_container = get_node("Columns/Menus Container/Loadout")
onready var objective_rows: Array = [
	get_node("Columns/Menus Container/Objectives Container/Objective Rows/Primary Container/Primary Panel/Primary Rows"),
	get_node("Columns/Menus Container/Objectives Container/Objective Rows/Secondary Container/Secondary Panel/Secondary Rows")
]
onready var objectives_button = get_node("Columns/Menu Buttons/Objectives Button")
onready var objectives_container = get_node("Columns/Menus Container/Objectives Container")
onready var secondary_objectives_container = get_node("Columns/Menus Container/Objectives Container/Objective Rows/Secondary Container")


func _ready():
	for brief_copy in MissionData.briefing:
		var brief_label = Label.new()
		brief_label.set_text(brief_copy)
		briefing_rows.add_child(brief_label)

	for index in range(objective_rows.size()):
		for objective in MissionData.objectives[index]:
			var objective_label = Label.new()
			objective_label.set_text(objective.name + ": " + objective.description)
			objective_rows[index].add_child(objective_label)

	if MissionData.objectives[Objective.SECONDARY].size() == 0:
		secondary_objectives_container.hide()

	briefing_button.connect("pressed", self, "_on_briefing_button_pressed")
	loadout_button.connect("pressed", self, "_on_loadout_button_pressed")
	objectives_button.connect("pressed", self, "_on_objectives_button_pressed")

	var start_button = get_node("Columns/Menus Container/Start Button")
	start_button.connect("pressed", self, "_on_start_button_pressed")

	var back_button = get_node("Columns/Menus Container/Back Button")
	back_button.connect("pressed", self, "_on_back_button_pressed")

	toggle_dyslexia(GlobalSettings.get_dyslexia())


func _on_back_button_pressed():
	if MissionData.is_in_campaign:
		SceneLoader.change_scene("res://title.tscn")
	else:
		SceneLoader.change_scene("res://mission_select.tscn")


func _on_briefing_button_pressed():
	briefing_container.show()
	loadout_container.hide()
	objectives_container.hide()


func _on_loadout_button_pressed():
	briefing_container.hide()
	loadout_container.show()
	objectives_container.hide()


func _on_objectives_button_pressed():
	briefing_container.hide()
	loadout_container.hide()
	objectives_container.show()


func _on_start_button_pressed():
	SceneLoader.load_scene(MissionData.mission_scene_path)


# PUBLIC


func toggle_dyslexia(toggle_on: bool):
	if toggle_on:
		set_theme(GlobalSettings.OPEN_DYSLEXIC_INTERFACE_THEME)
	else:
		set_theme(GlobalSettings.INCONSOLATA_INTERFACE_THEME)


const Objective = preload("Objective.gd")
