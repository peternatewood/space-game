extends AcceptDialog

onready var energy_weapon_items = get_node("Scroll Rows/Energy Weapons Scroll/Energy Weapon Items")
onready var missile_weapon_items = get_node("Scroll Rows/Missile Weapons Scroll/Missile Weapon Items")
onready var ship_items = get_node("Scroll Rows/Ships Scroll/Ship Items")


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
