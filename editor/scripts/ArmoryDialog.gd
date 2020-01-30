extends AcceptDialog

onready var energy_weapon_items = get_node("Scroll Rows/Energy Weapons Scroll/Energy Weapon Items")
onready var missile_weapon_items = get_node("Scroll Rows/Missile Weapons Scroll/Missile Weapon Items")
onready var mission_data = get_node("/root/MissionData")
onready var ship_items = get_node("Scroll Rows/Ships Scroll/Ship Items")


func _ready():
	var non_capital_ship_names: Array = []

	for ship_name in mission_data.ship_data.keys():
		if not mission_data.ship_data[ship_name].is_capital_ship:
			non_capital_ship_names.append(ship_name)

	populate_items(non_capital_ship_names, mission_data.energy_weapon_data.keys(), mission_data.missile_weapon_data.keys())


# PUBLIC


func get_armory():
	var armory = {
		"energy_weapons": [],
		"missile_weapons": [],
		"ships": []
	}

	for button in energy_weapon_items.get_children():
		if button.pressed:
			armory.energy_weapons.append(button.text)

	for button in missile_weapon_items.get_children():
		if button.pressed:
			armory.missile_weapons.append(button.text)

	for button in ship_items.get_children():
		if button.pressed:
			armory.ships.append(button.text)

	return armory


func populate_items(ship_names: Array, energy_weapon_names: Array, missile_weapon_names: Array):
	for ship in ship_names:
		var ship_check = CheckButton.new()
		ship_items.add_child(ship_check)
		ship_check.set_text(ship)

	for energy_weapon in energy_weapon_names:
		var energy_weapon_check = CheckButton.new()
		energy_weapon_items.add_child(energy_weapon_check)
		energy_weapon_check.set_text(energy_weapon)

	for missile_weapon in missile_weapon_names:
		var missile_weapon_check = CheckButton.new()
		missile_weapon_items.add_child(missile_weapon_check)
		missile_weapon_check.set_text(missile_weapon)


func set_items(ship_names: Array, energy_weapon_names: Array, missile_weapon_names: Array):
	for button in ship_items.get_children():
		button.set_pressed(ship_names.has(button.text))

	for button in energy_weapon_items.get_children():
		button.set_pressed(energy_weapon_names.has(button.text))

	for button in missile_weapon_items.get_children():
		button.set_pressed(missile_weapon_names.has(button.text))
