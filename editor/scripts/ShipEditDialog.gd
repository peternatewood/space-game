extends WindowDialog

onready var energy_weapon_labels: Array = [
	get_node("Ship Edit Rows/Ship Edit Grid/Energy Weapon Label 1"),
	get_node("Ship Edit Rows/Ship Edit Grid/Energy Weapon Label 2"),
	get_node("Ship Edit Rows/Ship Edit Grid/Energy Weapon Label 3")
]
onready var energy_weapon_options: Array = [
	get_node("Ship Edit Rows/Ship Edit Grid/Energy Weapon Options 1"),
	get_node("Ship Edit Rows/Ship Edit Grid/Energy Weapon Options 2"),
	get_node("Ship Edit Rows/Ship Edit Grid/Energy Weapon Options 3")
]
onready var grid = get_node("Ship Edit Rows/Ship Edit Grid")
onready var hitpoints_spinbox = get_node("Ship Edit Rows/Ship Edit Grid/Hitpoints SpinBox")
onready var missile_weapon_labels: Array = [
	get_node("Ship Edit Rows/Ship Edit Grid/Missile Weapon Label 1"),
	get_node("Ship Edit Rows/Ship Edit Grid/Missile Weapon Label 2"),
	get_node("Ship Edit Rows/Ship Edit Grid/Missile Weapon Label 3")
]
onready var missile_weapon_options: Array = [
	get_node("Ship Edit Rows/Ship Edit Grid/Missile Weapon Options 1"),
	get_node("Ship Edit Rows/Ship Edit Grid/Missile Weapon Options 2"),
	get_node("Ship Edit Rows/Ship Edit Grid/Missile Weapon Options 3")
]
onready var name_lineedit = get_node("Ship Edit Rows/Ship Edit Grid/Name LineEdit")
onready var player_ship_checkbox = get_node("Ship Edit Rows/Player Ship CheckBox")
onready var ship_class_options = get_node("Ship Edit Rows/Ship Edit Grid/Ship Class Options")
onready var wing_lineedit = get_node("Ship Edit Rows/Ship Edit Grid/Wing LineEdit")


func fill_ship_info(ship):
	hitpoints_spinbox.set_value(ship.hull_hitpoints)
	name_lineedit.set_text(ship.name)
	set_title("Edit " + ship.name)
	wing_lineedit.set_text(ship.wing_name)

	var energy_weapon_slot_count: int = 0
	var missile_weapon_slot_count: int = 0
	if ship is AttackShipBase:
		for ship_option_index in range(ship_class_options.get_item_count()):
			if ship_class_options.get_item_text(ship_option_index) == ship.ship_class:
				ship_class_options.select(ship_option_index)
				break

		energy_weapon_slot_count = ship.energy_weapon_hardpoints.size()
		missile_weapon_slot_count = ship.missile_weapon_hardpoints.size()

	for index in range(energy_weapon_options.size()):
		if index < energy_weapon_slot_count:
			energy_weapon_options[index].show()
			energy_weapon_labels[index].show()
		else:
			energy_weapon_options[index].hide()
			energy_weapon_labels[index].hide()

	for index in range(missile_weapon_options.size()):
		if index < missile_weapon_slot_count:
			missile_weapon_options[index].show()
			missile_weapon_labels[index].show()
		else:
			missile_weapon_options[index].hide()
			missile_weapon_labels[index].hide()

	player_ship_checkbox.set_pressed(ship is Player)


# According to the docs, Control.has_point does exist, but the engine disagrees
func has_point(point: Vector2):
	return rect_position.x < point.x and point.x < rect_position.x + rect_size.x and rect_position.y < point.y and point.y < rect_position.y + rect_size.y


func prepare_options(mission_data):
	for name in mission_data.ship_models.keys():
		ship_class_options.add_item(name)

	for name in mission_data.energy_weapon_models.keys():
		for option in energy_weapon_options:
			option.add_item(name)

	for name in mission_data.missile_weapon_models.keys():
		for option in missile_weapon_options:
			option.add_item(name)


const AttackShipBase = preload("res://scripts/AttackShipBase.gd")
const Player = preload("res://scripts/Player.gd")
