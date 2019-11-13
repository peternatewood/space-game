extends WindowDialog

onready var energy_weapon_labels: Array = [
	get_node("Ship Edit Grid/Energy Weapon Label 1"),
	get_node("Ship Edit Grid/Energy Weapon Label 2"),
	get_node("Ship Edit Grid/Energy Weapon Label 3")
]
onready var energy_weapon_options: Array = [
	get_node("Ship Edit Grid/Energy Weapon Options 1"),
	get_node("Ship Edit Grid/Energy Weapon Options 2"),
	get_node("Ship Edit Grid/Energy Weapon Options 3")
]
onready var grid = get_node("Ship Edit Grid")
onready var hitpoints_spinbox = get_node("Ship Edit Grid/Hitpoints SpinBox")
onready var missile_weapon_labels: Array = [
	get_node("Ship Edit Grid/Missile Weapon Label 1"),
	get_node("Ship Edit Grid/Missile Weapon Label 2"),
	get_node("Ship Edit Grid/Missile Weapon Label 3")
]
onready var missile_weapon_options: Array = [
	get_node("Ship Edit Grid/Missile Weapon Options 1"),
	get_node("Ship Edit Grid/Missile Weapon Options 2"),
	get_node("Ship Edit Grid/Missile Weapon Options 3")
]
onready var name_lineedit = get_node("Ship Edit Grid/Name LineEdit")
onready var ship_class_options = get_node("Ship Edit Grid/Ship Class Options")
onready var wing_lineedit = get_node("Ship Edit Grid/Ship Wing LineEdit")


# According to the docs, Control.has_point does exist, but the engine disagrees
func has_point(point: Vector2):
	return rect_position.x < point.x and point.x < rect_position.x + rect_size.x and rect_position.y < point.y and point.y < rect_position.y + rect_size.y


func prepare_options(mission_data):
	var ship_model_index: int = 0
	for name in mission_data.ship_models.keys():
		ship_class_options.add_item(name, ship_model_index)
		ship_model_index += 1

	var energy_model_index: int = 0
	for name in mission_data.energy_weapon_models.keys():
		for option in energy_weapon_options:
			option.add_item(name, energy_model_index)
		energy_model_index += 1

	var missile_model_index: int = 0
	for name in mission_data.missile_weapon_models.keys():
		for option in missile_weapon_options:
			option.add_item(name, missile_model_index)
		missile_model_index += 1
