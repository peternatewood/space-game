extends Control

onready var loader = get_node("/root/SceneLoader")
onready var mission_data = get_node("/root/MissionData")
onready var preview_viewport = get_node("Ship Preview Viewport")
onready var ship_preview = get_node("Database Rows/Tabs/Ships/Ship Preview Container")
onready var weapon_preview = get_node("Database Rows/Tabs/Weapons/Weapon Preview Container")


func _ready():
	var ship_list = get_node("Database Rows/Tabs/Ships/Ship List Scroll Container/Ship List")

	for ship_name in mission_data.ship_data.keys():
		if mission_data.ship_data[ship_name].in_database:
			var ship_button = Button.new()
			ship_list.add_child(ship_button)

			ship_button.set_text(ship_name)
			ship_button.set_text_align(Button.ALIGN_LEFT)
			ship_button.connect("pressed", self, "_on_ship_button_pressed", [ ship_name ])

	_on_ship_button_pressed("Spider Fighter")

	var weapon_list = get_node("Database Rows/Tabs/Weapons/Weapon List Scroll Container/Weapon List")

	for energy_weapon_name in mission_data.energy_weapon_data.keys():
		if mission_data.energy_weapon_data[energy_weapon_name].in_database:
			var energy_weapon_button = Button.new()
			weapon_list.add_child(energy_weapon_button)

			energy_weapon_button.set_text(energy_weapon_name)
			energy_weapon_button.set_text_align(Button.ALIGN_LEFT)
			energy_weapon_button.connect("pressed", self, "_on_energy_weapon_button_pressed", [ energy_weapon_name ])

	for missile_weapon_name in mission_data.missile_weapon_data.keys():
		if mission_data.missile_weapon_data[missile_weapon_name].in_database:
			var missile_weapon_button = Button.new()
			weapon_list.add_child(missile_weapon_button)

			missile_weapon_button.set_text(missile_weapon_name)
			missile_weapon_button.set_text_align(Button.ALIGN_LEFT)
			missile_weapon_button.connect("pressed", self, "_on_missile_weapon_button_pressed", [ missile_weapon_name ])

	for beam_weapon_name in mission_data.beam_weapon_data.keys():
		if mission_data.beam_weapon_data[beam_weapon_name].in_database:
			var beam_weapon_button = Button.new()
			weapon_list.add_child(beam_weapon_button)

			beam_weapon_button.set_text(beam_weapon_name)
			beam_weapon_button.set_text_align(Button.ALIGN_LEFT)
			beam_weapon_button.connect("pressed", self, "_on_beam_weapon_button_pressed", [ beam_weapon_name ])

	_on_energy_weapon_button_pressed("Energy Bolt")

	var back_button = get_node("Database Rows/Back Button")
	back_button.connect("pressed", self, "_on_back_pressed")


func _on_back_pressed():
	loader.change_scene("res://title.tscn")


func _on_beam_weapon_button_pressed(beam_weapon_name: String):
	var video_stream = load(mission_data.beam_weapon_data[beam_weapon_name].video_path)
	weapon_preview.set_weapon(beam_weapon_name, mission_data.beam_weapon_data[beam_weapon_name], video_stream)


func _on_energy_weapon_button_pressed(energy_weapon_name: String):
	var video_stream = load(mission_data.energy_weapon_data[energy_weapon_name].video_path)
	weapon_preview.set_weapon(energy_weapon_name, mission_data.energy_weapon_data[energy_weapon_name], video_stream)


func _on_missile_weapon_button_pressed(missile_weapon_name: String):
	var video_stream = load(mission_data.missile_weapon_data[missile_weapon_name].video_path)
	weapon_preview.set_weapon(missile_weapon_name, mission_data.missile_weapon_data[missile_weapon_name], video_stream)


func _on_ship_button_pressed(ship_name: String):
	var ship_model = load(mission_data.ship_data[ship_name].model_path)
	var ship_instance = ship_model.instance()

	ship_preview.set_ship(ship_name, mission_data.ship_data[ship_name], ship_instance)
