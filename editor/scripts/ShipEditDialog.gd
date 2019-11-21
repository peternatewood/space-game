extends Control

onready var capital_ship_options = get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Capital Ship Options")
onready var faction_options = get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Faction Options")
onready var hitpoints_spinbox = get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Hitpoints SpinBox")
onready var name_lineedit = get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Name LineEdit")
onready var next_button = get_node("Ship Edit Rows/Title Container/Next Button")
onready var npc_settings = get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/NPC Ship Rows")
onready var order_options: Array = [
	get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/NPC Ship Rows/Orders Grid/Order Type Option 1"),
	get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/NPC Ship Rows/Orders Grid/Order Type Option 2"),
	get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/NPC Ship Rows/Orders Grid/Order Type Option 3"),
	get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/NPC Ship Rows/Orders Grid/Order Type Option 4"),
	get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/NPC Ship Rows/Orders Grid/Order Type Option 5"),
	get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/NPC Ship Rows/Orders Grid/Order Type Option 6")
]
onready var player_ship_checkbox = get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Player Ship CheckBox")
onready var position_spinboxes: Dictionary = {
	"x": get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Transform Container/Position X SpinBox"),
	"y": get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Transform Container/Position Y SpinBox"),
	"z": get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Transform Container/Position Z SpinBox")
}
onready var previous_button = get_node("Ship Edit Rows/Title Container/Previous Button")
onready var rotation_spinboxes: Dictionary = {
	"x": get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Transform Container/Rotation X SpinBox"),
	"y": get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Transform Container/Rotation Y SpinBox"),
	"z": get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Transform Container/Rotation Z SpinBox")
}
onready var ship_class_options = get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Attack Ship Options")
onready var title = get_node("Ship Edit Rows/Title Container/Title")
onready var warped_in_checkbox = get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/NPC Ship Rows/Warped In CheckBox")
onready var wing_label = get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Wing Label")
onready var wing_options = get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Wing Options")

var beam_weapon_index_name_map: Array = []
var edit_ship = null
var energy_weapon_index_name_map: Array = []
var is_populating: bool = false
var missile_weapon_index_name_map: Array = []
var beam_weapon_labels: Array = []
var beam_weapon_options: Array = []
var energy_weapon_labels: Array = []
var energy_weapon_options: Array = []
var missile_weapon_labels: Array = []
var missile_weapon_options: Array = []


func _ready():
	# Grab weapon labels and slots
	var ship_edit_grid = get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid")
	for index in range(6):
		var number_str: String = str(index + 1)

		beam_weapon_labels.append(ship_edit_grid.get_node("Beam Weapon Label " + number_str))
		beam_weapon_options.append(ship_edit_grid.get_node("Beam Weapon Options " + number_str))
		energy_weapon_labels.append(ship_edit_grid.get_node("Energy Weapon Label " + number_str))
		energy_weapon_options.append(ship_edit_grid.get_node("Energy Weapon Options " + number_str))
		missile_weapon_labels.append(ship_edit_grid.get_node("Missile Weapon Label " + number_str))
		missile_weapon_options.append(ship_edit_grid.get_node("Missile Weapon Options " + number_str))

	player_ship_checkbox.connect("toggled", self, "_on_player_ship_toggled")

	position_spinboxes.x.connect("value_changed", self, "_on_position_x_changed")
	position_spinboxes.y.connect("value_changed", self, "_on_position_y_changed")
	position_spinboxes.z.connect("value_changed", self, "_on_position_z_changed")

	rotation_spinboxes.x.connect("value_changed", self, "_on_rotation_x_changed")
	rotation_spinboxes.y.connect("value_changed", self, "_on_rotation_y_changed")
	rotation_spinboxes.z.connect("value_changed", self, "_on_rotation_z_changed")

	var update_button = get_node("Ship Edit Rows/Update Button")
	update_button.connect("pressed", self, "_on_update_pressed")


func _on_player_ship_toggled(button_pressed: bool):
	if not is_populating:
		if button_pressed:
			npc_settings.hide()
		else:
			npc_settings.show()

#		emit_signal("player_ship_toggled", button_pressed)


func _on_position_x_changed(new_value: float):
	if not is_populating:
		edit_ship.transform.origin.x = new_value
		emit_signal("ship_position_changed", edit_ship.transform.origin)


func _on_position_y_changed(new_value: float):
	if not is_populating:
		edit_ship.transform.origin.y = new_value
		emit_signal("ship_position_changed", edit_ship.transform.origin)


func _on_position_z_changed(new_value: float):
	if not is_populating:
		edit_ship.transform.origin.z = new_value
		emit_signal("ship_position_changed", edit_ship.transform.origin)


func _on_rotation_x_changed(new_value: float):
	if not is_populating:
		edit_ship.rotation_degrees.x = new_value
		emit_signal("ship_rotation_changed", edit_ship.rotation_degrees)


func _on_rotation_y_changed(new_value: float):
	if not is_populating:
		edit_ship.rotation_degrees.y = new_value
		emit_signal("ship_rotation_changed", edit_ship.rotation_degrees)


func _on_rotation_z_changed(new_value: float):
	if not is_populating:
		edit_ship.rotation_degrees.z = new_value
		emit_signal("ship_rotation_changed", edit_ship.rotation_degrees)


func _on_update_pressed():
	title.set_text("Edit " + name_lineedit.text)
	emit_signal("update_pressed")


# PUBLIC


func fill_ship_info(ship, loadout: Dictionary = {}):
	is_populating = true

	if ship.hull_hitpoints == -1:
		hitpoints_spinbox.set_value(ship.get_meta("hull_hitpoints"))
	else:
		hitpoints_spinbox.set_value(ship.hull_hitpoints)

	name_lineedit.set_text(ship.name)
	title.set_text("Edit " + ship.name)

	position_spinboxes.x.set_value(ship.transform.origin.x)
	position_spinboxes.y.set_value(ship.transform.origin.y)
	position_spinboxes.z.set_value(ship.transform.origin.z)

	rotation_spinboxes.x.set_value(ship.rotation_degrees.x)
	rotation_spinboxes.y.set_value(ship.rotation_degrees.y)
	rotation_spinboxes.z.set_value(ship.rotation_degrees.z)

	faction_options.select(0)
	for index in range(faction_options.get_item_count()):
		if faction_options.get_item_text(index) == ship.faction:
			faction_options.select(index)
			break

	var beam_weapon_slot_count: int = 0
	var energy_weapon_slot_count: int = 0
	var missile_weapon_slot_count: int = 0

	var beam_weapons: Array = loadout.get("beam_weapons", [])
	var energy_weapons: Array = loadout.get("energy_weapons", [])
	var missile_weapons: Array = loadout.get("missile_weapons", [])

	wing_options.select(0)
	if ship is AttackShipBase:
		ship_class_options.show()
		capital_ship_options.hide()
		player_ship_checkbox.show()
		wing_label.show()
		wing_options.show()

		for index in range(wing_options.get_item_count()):
			if wing_options.get_item_text(index) == ship.wing_name:
				wing_options.select(index)
				break
		for ship_option_index in range(ship_class_options.get_item_count()):
			if ship_class_options.get_item_text(ship_option_index) == ship.ship_class:
				ship_class_options.select(ship_option_index)
				break

		energy_weapon_slot_count = ship.energy_weapon_hardpoints.size()
		missile_weapon_slot_count = ship.missile_weapon_hardpoints.size()
	elif ship is CapitalShipBase:
		ship_class_options.hide()
		capital_ship_options.show()
		player_ship_checkbox.hide()
		wing_label.hide()
		wing_options.hide()

		beam_weapon_slot_count = ship.beam_weapon_turrets.size()
		energy_weapon_slot_count = ship.energy_weapon_turrets.size()
		missile_weapon_slot_count = ship.missile_weapon_turrets.size()

	for index in range(beam_weapon_options.size()):
		if index < beam_weapon_slot_count:
			var beam_weapon_options_index = beam_weapon_index_name_map.find(beam_weapons[index])
			# Add one since the first item is "none" and the index will be "-1" if the item isn't found
			beam_weapon_options[index].select(beam_weapon_options_index + 1)

			beam_weapon_options[index].show()
			beam_weapon_labels[index].show()
		else:
			beam_weapon_options[index].hide()
			beam_weapon_labels[index].hide()

	for index in range(energy_weapon_options.size()):
		if index < energy_weapon_slot_count:
			var energy_weapon_options_index = energy_weapon_index_name_map.find(energy_weapons[index])
			# Add one since the first item is "none" and the index will be "-1" if the item isn't found
			energy_weapon_options[index].select(energy_weapon_options_index + 1)

			energy_weapon_options[index].show()
			energy_weapon_labels[index].show()
		else:
			energy_weapon_options[index].hide()
			energy_weapon_labels[index].hide()

	for index in range(missile_weapon_options.size()):
		if index < missile_weapon_slot_count:
			var missile_weapon_options_index = missile_weapon_index_name_map.find(missile_weapons[index])
			# Add one since the first item is "none" and the index will be "-1" if the item isn't found
			missile_weapon_options[index].select(missile_weapon_options_index + 1)

			missile_weapon_options[index].show()
			missile_weapon_labels[index].show()
		else:
			missile_weapon_options[index].hide()
			missile_weapon_labels[index].hide()

	var is_player = ship is Player
	player_ship_checkbox.set_pressed(is_player)

	if is_player:
		npc_settings.hide()
	elif ship is ShipBase:
		warped_in_checkbox.set_pressed(ship.is_warped_in)

		for index in range(order_options.size()):
			order_options[index].select(ship.initial_orders[index])

		npc_settings.show()

	edit_ship = ship
	is_populating = false


func get_energy_weapon_selections():
	var energy_weapon_names: Array = []

	for option in energy_weapon_options:
		var selected_id = option.get_selected_id()
		if selected_id == 0:
			energy_weapon_names.append("none")
		else:
			energy_weapon_names.append(energy_weapon_index_name_map[selected_id - 1])

	return energy_weapon_names


func get_faction_name():
	return faction_options.get_item_text(faction_options.get_selected_id())


func get_missile_weapon_selections():
	var missile_weapon_names: Array = []

	for option in missile_weapon_options:
		var selected_id = option.get_selected_id()
		if selected_id == 0:
			missile_weapon_names.append("none")
		else:
			missile_weapon_names.append(missile_weapon_index_name_map[selected_id - 1])

	return missile_weapon_names


func get_orders():
	var orders_list: Array = []

	for option in order_options:
		orders_list.append(option.get_selected_id())

	return orders_list


func get_wing_index():
	return wing_options.get_selected_id() - 1


# According to the docs, Control.has_point does exist, but the engine disagrees
func has_point(point: Vector2):
	return rect_position.x < point.x and point.x < rect_position.x + rect_size.x and rect_position.y < point.y and point.y < rect_position.y + rect_size.y


func populate_wing_options(wing_names: Array):
	for index in range(wing_names.size()):
		var is_empty: bool = wing_names[index] == ""

		if is_empty:
			wing_options.set_item_text(index + 1, "none")
		else:
			wing_options.set_item_text(index + 1, wing_names[index])

		wing_options.set_item_disabled(index + 1, is_empty)


func prepare_options(mission_data, mission_node):
	var ship_index: int = 0
	for name in mission_data.ship_models.keys():
		ship_class_options.add_item(name, ship_index)
		ship_index += 1

	ship_index = 0
	for name in mission_data.capital_ship_models.keys():
		capital_ship_options.add_item(name, ship_index)
		ship_index += 1

	# Start at one since the first option "none" is at index 0
	var energy_weapon_index: int = 1
	for name in mission_data.energy_weapon_models.keys():
		for option in energy_weapon_options:
			option.add_item(name, energy_weapon_index)
		energy_weapon_index += 1

	# Start at one since the first option "none" is at index 0
	var missile_weapon_index: int = 1
	for name in mission_data.missile_weapon_models.keys():
		for option in missile_weapon_options:
			option.add_item(name, missile_weapon_index)
		missile_weapon_index += 1

	var faction_index: int = 1
	for faction_name in mission_node.factions.keys():
		faction_options.add_item(faction_name, faction_index)
		faction_index += 1


signal ship_position_changed
signal ship_rotation_changed
signal update_pressed

const AttackShipBase = preload("res://scripts/AttackShipBase.gd")
const CapitalShipBase = preload("res://scripts/CapitalShipBase.gd")
const NPCShip = preload("res://scripts/NPCShip.gd")
const Player = preload("res://scripts/Player.gd")
const ShipBase = preload("res://scripts/ShipBase.gd")
