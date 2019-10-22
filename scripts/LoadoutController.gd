extends Control

onready var energy_weapon_slots = get_node("Weapon Slots Rows/Energy Weapon Rows").get_children()
onready var loader = get_node("/root/SceneLoader")
onready var missile_weapon_slots = get_node("Weapon Slots Rows/Missile Weapon Rows").get_children()
onready var mission_data = get_node("/root/MissionData")
onready var ship_class_label = get_node("Ship Preview Container/Ship Details/Ship Class")
onready var ship_overhead = get_node("Ship Overhead")
onready var ship_preview = get_node("Ship Preview Viewport")
onready var ship_preview_container = get_node("Ship Preview Container")
onready var ship_selection_container = get_node("Left Rows/Ships Panel/Ship Selection Container")
onready var start_button = get_node("Start Button")
onready var wing_ships_container = get_node("Wing Ships Container")

var current_ship_class: String
var editing_ship_index: int = 0
var editing_wing_name: String
var energy_weapon_data: Dictionary = {}
var missile_weapon_data: Dictionary = {}
var mouse_over_wing_ship: bool = false
var ship_data: Dictionary = {}
var wing_ship_over
var wing_containers: Dictionary = {}


func _ready():
	# Map wing names to container nodes
	var wing_container_nodes = wing_ships_container.get_children()
	for index in range(min(mission_data.VALID_WINGS.size(), wing_container_nodes.size())):
		wing_containers[mission_data.VALID_WINGS[index]] = wing_container_nodes[index]

	for dir in SHIP_DIRECTORIES:
		var model = load("res://models/ships/" + dir + "/model.dae")
		if model != null:
			var ship_instance = model.instance()
			var ship_class = ship_instance.get_meta("ship_class")

			var icon = ImageTexture.new()
			var icon_load_error = icon.load("res://models/ships/" + dir + "/overhead.png")
			if icon_load_error != OK:
				print("Error loading ship icon: " + str(icon_load_error))

			var overhead = ImageTexture.new()
			var overhead_load_error = overhead.load("res://models/ships/" + dir + "/loadout_overhead.png")
			if overhead_load_error != OK:
				print("Error loading overhead icon: " + str(overhead_load_error))

			var loadout_icon = SHIP_DRAGGABLE_ICON.instance()
			ship_selection_container.add_child(loadout_icon)
			loadout_icon.set_ship(ship_class, icon)
			loadout_icon.connect("icon_clicked", self, "_on_loadout_icon_clicked")
			loadout_icon.connect("draggable_icon_dropped", self, "_on_draggable_ship_icon_dropped")

			ship_data[ship_class] = { "model": model, "icon": icon, "overhead": overhead }

	var energy_weapons_container = get_node("Left Rows/Energy Weapons Panel/Energy Weapons Container")
	for dir in ENERGY_WEAPON_DIRECTORIES:
		var model = load("res://models/energy_weapons/" + dir + "/model.dae")
		if model != null:
			var energy_weapon_instance = model.instance()
			var energy_weapon_name: String = energy_weapon_instance.get_meta("weapon_name")

			var icon = ImageTexture.new()
			var icon_load_error = icon.load("res://models/energy_weapons/" + dir + "/overhead.png")
			if icon_load_error != OK:
				print("Error loading ship icon: " + str(icon_load_error))

			var overhead = ImageTexture.new()
			var overhead_load_error = overhead.load("res://models/energy_weapons/" + dir + "/overhead.png")
			if overhead_load_error != OK:
				print("Error loading overhead icon: " + str(overhead_load_error))

			var loadout_icon = WEAPON_DRAGGABLE_ICON.instance()
			energy_weapons_container.add_child(loadout_icon)
			loadout_icon.set_weapon(energy_weapon_name, icon, WeaponSlot.TYPE.ENERGY_WEAPON)
			loadout_icon.connect("draggable_icon_dropped", self, "_on_draggable_weapon_icon_dropped")

			energy_weapon_data[energy_weapon_name] = { "model": model, "icon": icon, "overhead": overhead }

	var missile_weapons_container = get_node("Left Rows/Missile Weapons Panel/Missile Weapons Container")
	for dir in MISSILE_WEAPON_DIRECTORIES:
		var model = load("res://models/missile_weapons/" + dir + "/model.dae")
		if model != null:
			var missile_instance = model.instance()
			var missile_weapon_name: String = missile_instance.get_meta("weapon_name")

			var icon = ImageTexture.new()
			var icon_load_error = icon.load("res://models/missile_weapons/" + dir + "/overhead.png")
			if icon_load_error != OK:
				print("Error loading ship icon: " + str(icon_load_error))

			var overhead = ImageTexture.new()
			var overhead_load_error = overhead.load("res://models/missile_weapons/" + dir + "/overhead.png")
			if overhead_load_error != OK:
				print("Error loading overhead icon: " + str(overhead_load_error))

			var loadout_icon = WEAPON_DRAGGABLE_ICON.instance()
			missile_weapons_container.add_child(loadout_icon)
			loadout_icon.set_weapon(missile_weapon_name, icon, WeaponSlot.TYPE.MISSILE_WEAPON)
			loadout_icon.connect("draggable_icon_dropped", self, "_on_draggable_weapon_icon_dropped")

			missile_weapon_data[missile_weapon_name] = { "model": model, "icon": icon, "overhead": overhead }

	# Set wing ship icons based on wing defaults
	for wing_name in wing_containers.keys():
		var ship_icons = wing_containers[wing_name].get_children()
		for ship_index in range(4):
			if ship_index < mission_data.wing_loadouts[wing_name].size():
				var ship_class = mission_data.wing_loadouts[wing_name][ship_index].ship_class
				ship_icons[ship_index].set_icon(ship_data[ship_class].icon)
				ship_icons[ship_index].set_indexes(wing_name, ship_index)
				ship_icons[ship_index].connect("pressed", self, "_on_wing_icon_pressed", [ wing_name, ship_index ])
			else:
				ship_icons[ship_index].disable()

	var index: int = 0
	for node in get_node("Left Rows/Wings Panel/Wing Selection Container").get_children():
		if node is CheckBox:
			node.connect("pressed", self, "_on_wing_checkbox_pressed", [ mission_data.VALID_WINGS[index] ])
			index += 1

	start_button.connect("pressed", self, "_on_start_button_pressed")


func _on_draggable_ship_icon_dropped(icon, over_area):
	if over_area is ShipSlot:
		over_area.set_icon(icon.get_texture())
		over_area.highlight(false)
		# Set current wing ship selection to icon we dropped over
		_set_editing_ship(icon.ship_class, over_area.wing_name, over_area.ship_index)


func _on_draggable_weapon_icon_dropped(icon, over_area):
	if over_area is WeaponSlot and over_area.is_area_same_type(icon.draggable_icon):
		over_area.set_icon(icon.get_texture())
		over_area.highlight(false)
		# TODO: assign weapon to currently selected ship in this slot


func _on_loadout_icon_clicked(icon):
	_update_ship_preview(icon.ship_class)


func _on_start_button_pressed():
	print(mission_data.mission_scene_path)
	loader.change_scene(mission_data.mission_scene_path)


func _on_wing_checkbox_pressed(pressed_wing_name: String):
	for wing_name in wing_containers.keys():
		wing_containers[wing_name].toggle(wing_name == pressed_wing_name)


func _on_wing_icon_pressed(wing_name: String, ship_index: int):
	_set_editing_ship(mission_data.wing_loadouts[wing_name][ship_index].ship_class, wing_name, ship_index)


func _set_editing_ship(ship_class: String, wing_name: String, ship_index: int):
	_update_ship_preview(ship_class)
	ship_overhead.set_texture(ship_data[ship_class].overhead)
	mission_data.wing_loadouts[wing_name][ship_index].ship_class = ship_class

	# Update weapon slot icons
	var ship_loadout = mission_data.wing_loadouts[wing_name][ship_index]
	for index in range(energy_weapon_slots.size()):
		if index < ship_loadout.energy_weapons.size():
			energy_weapon_slots[index].set_icon(energy_weapon_data[ship_loadout.energy_weapons[index]].icon)
			energy_weapon_slots[index].show()
		else:
			energy_weapon_slots[index].hide()

	for index in range(missile_weapon_slots.size()):
		if index < ship_loadout.missile_weapons.size():
			missile_weapon_slots[index].set_icon(missile_weapon_data[ship_loadout.missile_weapons[index]].icon)
			missile_weapon_slots[index].show()
		else:
			missile_weapon_slots[index].hide()

	editing_wing_name = wing_name
	editing_ship_index = ship_index


func _update_ship_preview(ship_class: String):
	if ship_class != current_ship_class:
		current_ship_class = ship_class

		ship_preview_container.show()
		ship_class_label.set_text(current_ship_class)
		ship_preview.show_ship(ship_data[current_ship_class].model)

		return true

	return false


const DraggableIcon = preload("DraggableIcon.gd")
const WeaponSlot = preload("WeaponSlot.gd")
const ShipSlot = preload("ShipSlot.gd")

const ENERGY_WEAPON_DIRECTORIES: Array = [ "disintigrator", "energy_bolt" ]
const MISSILE_WEAPON_DIRECTORIES: Array = [ "heat_seeker" ]
const SHIP_DIRECTORIES: Array = [ "fighter_frog", "fighter_hawk", "fighter_spider" ]
const SHIP_DRAGGABLE_ICON = preload("res://icons/ship_draggable_icon.tscn")
const WEAPON_DRAGGABLE_ICON = preload("res://icons/weapon_draggable_icon.tscn")
