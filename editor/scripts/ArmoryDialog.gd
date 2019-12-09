extends AcceptDialog

onready var ship_items = get_node("Scroll Rows/Ships Scroll/Ship Items")
onready var weapon_items = get_node("Scroll Rows/Weapons Scroll/Weapon Items")


func populate_items(ship_names: Array, energy_weapon_names: Array, missile_weapon_names: Array):
	for ship in ship_names:
		var ship_check = CheckButton.new()
		ship_items.add_child(ship_check)
		ship_check.set_text(ship)

	for energy_weapon in energy_weapon_names:
		var weapon_check = CheckButton.new()
		weapon_items.add_child(weapon_check)
		weapon_check.set_text(energy_weapon)

	for missile_weapon in missile_weapon_names:
		var weapon_check = CheckButton.new()
		weapon_items.add_child(weapon_check)
		weapon_check.set_text(missile_weapon)
