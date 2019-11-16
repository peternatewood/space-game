extends Control

onready var energy_weapon_labels: Array = [
	get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Energy Weapon Label 1"),
	get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Energy Weapon Label 2"),
	get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Energy Weapon Label 3")
]
onready var energy_weapon_options: Array = [
	get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Energy Weapon Options 1"),
	get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Energy Weapon Options 2"),
	get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Energy Weapon Options 3")
]
onready var hitpoints_spinbox = get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Hitpoints SpinBox")
onready var missile_weapon_labels: Array = [
	get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Missile Weapon Label 1"),
	get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Missile Weapon Label 2"),
	get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Missile Weapon Label 3")
]
onready var missile_weapon_options: Array = [
	get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Missile Weapon Options 1"),
	get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Missile Weapon Options 2"),
	get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Missile Weapon Options 3")
]
onready var name_lineedit = get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Name LineEdit")
onready var next_button = get_node("Ship Edit Rows/Title Container/Next Button")
onready var npc_settings = get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/NPC Ship Rows")
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
onready var title = get_node("Ship Edit Rows/Title Container/Title")
onready var ship_class_options = get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Ship Class Options")
onready var warped_in_checkbox = get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/NPC Ship Rows/Warped In CheckBox")
onready var wing_lineedit = get_node("Ship Edit Rows/Ship Edit Scroll/Ship Edit Scroll Rows/Ship Edit Grid/Wing LineEdit")

var edit_ship = null
var energy_weapon_index_name_map: Array = []
var is_populating: bool = false
var missile_weapon_index_name_map: Array = []


func _ready():
	hitpoints_spinbox.connect("value_changed", self, "_on_hitpoints_changed")
	name_lineedit.connect("text_changed", self, "_on_name_changed")
	player_ship_checkbox.connect("toggled", self, "_on_player_ship_toggled")
	ship_class_options.connect("item_selected", self, "_on_ship_class_changed")
	warped_in_checkbox.connect("toggled", self, "_on_warped_in_toggled")
	wing_lineedit.connect("text_changed", self, "_on_wing_changed")

	position_spinboxes.x.connect("value_changed", self, "_on_position_x_changed")
	position_spinboxes.y.connect("value_changed", self, "_on_position_y_changed")
	position_spinboxes.z.connect("value_changed", self, "_on_position_z_changed")

	rotation_spinboxes.x.connect("value_changed", self, "_on_rotation_x_changed")
	rotation_spinboxes.y.connect("value_changed", self, "_on_rotation_y_changed")
	rotation_spinboxes.z.connect("value_changed", self, "_on_rotation_z_changed")

	var energy_weapon_index: int = 0
	for option in energy_weapon_options:
		option.connect("item_selected", self, "_on_ship_energy_weapon_changed", [ energy_weapon_index ])
		energy_weapon_index += 1

	var missile_weapon_index: int = 0
	for option in missile_weapon_options:
		option.connect("item_selected", self, "_on_ship_missile_weapon_changed", [ missile_weapon_index ])
		missile_weapon_index += 1


func _on_hitpoints_changed(new_value: float):
	if not is_populating:
		edit_ship.hull_hitpoints = int(new_value)


func _on_name_changed(new_text: String):
	if not is_populating:
		var old_name = edit_ship.name
		edit_ship.set_name(new_text)
		title.set_text("Edit " + edit_ship.name)
		emit_signal("ship_name_changed", old_name, edit_ship.name)


func _on_player_ship_toggled(button_pressed: bool):
	if button_pressed:
		npc_settings.hide()
	else:
		npc_settings.show()

	emit_signal("player_ship_toggled", button_pressed)


func _on_position_x_changed(new_value: float):
	edit_ship.transform.origin.x = new_value
	emit_signal("ship_position_changed", edit_ship.transform.origin)


func _on_position_y_changed(new_value: float):
	edit_ship.transform.origin.y = new_value
	emit_signal("ship_position_changed", edit_ship.transform.origin)


func _on_position_z_changed(new_value: float):
	edit_ship.transform.origin.z = new_value
	emit_signal("ship_position_changed", edit_ship.transform.origin)


func _on_rotation_x_changed(new_value: float):
	edit_ship.rotation_degrees.x = new_value
	emit_signal("ship_rotation_changed", edit_ship.rotation_degrees)


func _on_rotation_y_changed(new_value: float):
	edit_ship.rotation_degrees.y = new_value
	emit_signal("ship_rotation_changed", edit_ship.rotation_degrees)


func _on_rotation_z_changed(new_value: float):
	edit_ship.rotation_degrees.z = new_value
	emit_signal("ship_rotation_changed", edit_ship.rotation_degrees)


func _on_ship_class_changed(item_index: int):
	emit_signal("ship_class_changed", item_index)


func _on_ship_energy_weapon_changed(item_index: int, slot_index: int):
	var weapon_name: String = "none"
	if item_index != 0:
		# The first item at [0] is "none", so we have to subtract one
		weapon_name = energy_weapon_index_name_map[item_index - 1]

	emit_signal("ship_energy_weapon_changed", weapon_name, slot_index)


func _on_ship_missile_weapon_changed(item_index: int, slot_index: int):
	var weapon_name: String
	if item_index != 0:
		# The first item at [0] is "none", so we have to subtract one
		weapon_name = missile_weapon_index_name_map[item_index - 1]

	emit_signal("ship_missile_weapon_changed", weapon_name, slot_index)


func _on_warped_in_toggled(button_pressed: bool):
	edit_ship.is_warped_in = button_pressed


func _on_wing_changed(new_text: String):
	if not is_populating:
		# TODO: Ensure only valid characters are entered
		edit_ship.wing_name = new_text


# PUBLIC


func fill_ship_info(ship, loadout: Dictionary = {}):
	is_populating = true

	if ship.hull_hitpoints == -1:
		hitpoints_spinbox.set_value(ship.get_meta("hull_hitpoints"))
	else:
		hitpoints_spinbox.set_value(ship.hull_hitpoints)

	name_lineedit.set_text(ship.name)
	title.set_text("Edit " + ship.name)
	wing_lineedit.set_text(ship.wing_name)

	position_spinboxes.x.set_value(ship.transform.origin.x)
	position_spinboxes.y.set_value(ship.transform.origin.y)
	position_spinboxes.z.set_value(ship.transform.origin.z)

	rotation_spinboxes.x.set_value(ship.rotation_degrees.x)
	rotation_spinboxes.y.set_value(ship.rotation_degrees.y)
	rotation_spinboxes.z.set_value(ship.rotation_degrees.z)

	var energy_weapon_slot_count: int = 0
	var missile_weapon_slot_count: int = 0

	var energy_weapons: Array = loadout.get("energy_weapons", [])
	var missile_weapons: Array = loadout.get("missile_weapons", [])

	if ship is AttackShipBase:
		for ship_option_index in range(ship_class_options.get_item_count()):
			if ship_class_options.get_item_text(ship_option_index) == ship.ship_class:
				ship_class_options.select(ship_option_index)
				break

		energy_weapon_slot_count = ship.energy_weapon_hardpoints.size()
		missile_weapon_slot_count = ship.missile_weapon_hardpoints.size()

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
		npc_settings.show()

	edit_ship = ship
	is_populating = false


# According to the docs, Control.has_point does exist, but the engine disagrees
func has_point(point: Vector2):
	return rect_position.x < point.x and point.x < rect_position.x + rect_size.x and rect_position.y < point.y and point.y < rect_position.y + rect_size.y


func prepare_options(mission_data):
	var ship_index: int = 0
	for name in mission_data.ship_models.keys():
		ship_class_options.add_item(name, ship_index)
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


signal player_ship_toggled
signal ship_class_changed
signal ship_energy_weapon_changed
signal ship_missile_weapon_changed
signal ship_name_changed
signal ship_position_changed
signal ship_rotation_changed

const AttackShipBase = preload("res://scripts/AttackShipBase.gd")
const NPCShip = preload("res://scripts/NPCShip.gd")
const Player = preload("res://scripts/Player.gd")
const ShipBase = preload("res://scripts/ShipBase.gd")
