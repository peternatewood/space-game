extends Control

onready var draggable_icon = get_node("Draggable Icon")
onready var energy_weapon_slots = get_node("Weapon Slots Rows/Energy Weapon Rows").get_children()
onready var missile_weapon_slots = get_node("Weapon Slots Rows/Missile Weapon Rows").get_children()
onready var ship_overhead = get_node("Ship Overhead")
onready var ship_preview_container = get_node("Ship Preview Container")
onready var ship_wing_name = get_node("Weapon Slots Rows/Ship Wing Name")
onready var weapon_slots_rows = get_node("Weapon Slots Rows")
onready var weapon_preview_container = get_node("Weapon Preview Container")
onready var wing_containers = get_node("Wing Ships Container").get_children()

var current_ship_class: String
var editing_ship_index: int = -1
var editing_wing_index: int = -1
var energy_weapon_resources: Dictionary = {}
var missile_weapon_resources: Dictionary = {}
var ship_resources: Dictionary = {}
var wing_ship_over


func _ready():
	var ship_selection_container = get_node("Left Rows/Ships Panel/Ships Scroll/Ship Selection Container")
	for section in MissionData.ship_data.keys():
		var ship_class = MissionData.ship_data[section].get("ship_class", "")

		if MissionData.armory.ships.has(ship_class):
			var model = load(MissionData.ship_data[section].model_path)

			var icon = ImageTexture.new()
			var icon_stream_texture = load(MissionData.ship_data[ship_class].icon_path)
			var icon_texture = icon_stream_texture.get_data()
			icon.create_from_image(icon_texture, 0)

			var overhead = ImageTexture.new()
			var overhead_stream_texture = load(MissionData.ship_data[ship_class].loadout_overhead_path)
			var overhead_texture = overhead_stream_texture.get_data()
			overhead.create_from_image(overhead_texture, 0)

			var loadout_icon = LOADOUT_ICON.instance()
			ship_selection_container.add_child(loadout_icon)
			loadout_icon.set_ship(ship_class, icon)
			loadout_icon.connect("pressed", self, "_update_ship_preview", [ ship_class ])

			ship_resources[ship_class] = {
				"model": model,
				"icon": icon,
				"overhead": overhead
			}

	var energy_weapons_container = get_node("Left Rows/Energy Weapons Panel/Energy Weapons Scroll/Energy Weapons Container")
	for energy_weapon_name in MissionData.energy_weapon_data.keys():
		if MissionData.armory.energy_weapons.has(energy_weapon_name):
			var model = load(MissionData.energy_weapon_data[energy_weapon_name].model_path)

			var icon = ImageTexture.new()
			var icon_stream_texture = load(MissionData.energy_weapon_data[energy_weapon_name].icon_path)
			var icon_texture = icon_stream_texture.get_data()
			icon.create_from_image(icon_texture, 0)

			var energy_weapon_icon = LOADOUT_ICON.instance()
			energy_weapons_container.add_child(energy_weapon_icon)
			energy_weapon_icon.set_weapon(energy_weapon_name, icon)
			energy_weapon_icon.connect("pressed", self, "_update_weapon_preview", [ "energy_weapon", energy_weapon_name ])

			var energy_weapon_video = load(MissionData.energy_weapon_data[energy_weapon_name].video_path)

			energy_weapon_resources[energy_weapon_name] = {
				"icon": icon,
				"model": model,
				"video": energy_weapon_video
			}

	for index in range(energy_weapon_slots.size()):
		energy_weapon_slots[index].set_options(energy_weapon_resources)
		energy_weapon_slots[index].connect("icon_pressed", self, "_on_energy_weapon_slot_pressed", [ index ])

	var missile_weapons_container = get_node("Left Rows/Missile Weapons Panel/Missile Weapons Scroll/Missile Weapons Container")
	for missile_weapon_name in MissionData.missile_weapon_data.keys():
		if MissionData.armory.missile_weapons.has(missile_weapon_name):
			var model = load(MissionData.missile_weapon_data[missile_weapon_name].model_path)

			var icon = ImageTexture.new()
			var icon_stream_texture = load(MissionData.missile_weapon_data[missile_weapon_name].icon_path)
			var icon_texture = icon_stream_texture.get_data()
			icon.create_from_image(icon_texture, 0)

			var missile_weapon_icon = LOADOUT_ICON.instance()
			missile_weapons_container.add_child(missile_weapon_icon)
			missile_weapon_icon.set_weapon(missile_weapon_name, icon)
			missile_weapon_icon.connect("pressed", self, "_update_weapon_preview", [ "missile_weapon", missile_weapon_name ])

			var missile_weapon_video = load(MissionData.missile_weapon_data[missile_weapon_name].video_path)

			missile_weapon_resources[missile_weapon_name] = {
				"icon": icon,
				"model": model,
				"video": missile_weapon_video
			}

	for index in range(missile_weapon_slots.size()):
		missile_weapon_slots[index].set_options(missile_weapon_resources)
		missile_weapon_slots[index].connect("icon_pressed", self, "_on_missile_weapon_slot_pressed", [ index ])

	# Create wing checkboxes
	var wing_selection_checkboxes = get_node("Left Rows/Wings Panel/Wing Selection Container").get_children()
	var wing_index: int = 0

	for index in range(wing_selection_checkboxes.size()):
		var checkbox = wing_selection_checkboxes[index]
		var wing_name = MissionData.wing_names[index]

		if wing_name == "":
			checkbox.hide()
		else:
			checkbox.set_text(MissionData.wing_names[index])
			checkbox.connect("pressed", self, "_on_wing_checkbox_pressed", [ index ])

	# Set wing ship icons based on wing defaults
	var wing_count: int = MissionData.wing_loadouts.size()
	for wing_index in range(wing_containers.size()):
		if wing_index < wing_count:
			var ship_count: int = MissionData.wing_loadouts[wing_index].size()

			for ship_index in range(4):
				if ship_index < ship_count:
					var ship_class: String = MissionData.wing_loadouts[wing_index][ship_index].get("ship_class", "")

					wing_containers[wing_index].get_child(ship_index).set_options(ship_resources)
					wing_containers[wing_index].get_child(ship_index).set_current_icon(ship_resources[ship_class].icon)
					wing_containers[wing_index].get_child(ship_index).connect("selection_pressed", self, "_on_wing_selection_pressed", [ wing_index, ship_index ])
					wing_containers[wing_index].get_child(ship_index).connect("icon_pressed", self, "_on_wing_icon_pressed")
				else:
					wing_containers[wing_index].get_child(ship_index).disable()
		else:
			wing_containers[wing_index].hide()

	# Default to showing player/Alpha 1 loadout
	_on_wing_selection_pressed(0, 0)


func _on_energy_weapon_slot_pressed(weapon_name: String, slot_index: int):
	if editing_wing_index == -1 or editing_ship_index == -1:
		print("Something went wrong!")
	elif weapon_name != MissionData.wing_loadouts[editing_wing_index][editing_ship_index].energy_weapons[slot_index].name:
		MissionData.wing_loadouts[editing_wing_index][editing_ship_index].energy_weapons[slot_index].model = energy_weapon_resources[weapon_name].model
		MissionData.wing_loadouts[editing_wing_index][editing_ship_index].energy_weapons[slot_index].name = weapon_name


func _on_missile_weapon_slot_pressed(weapon_name: String, slot_index: int):
	if editing_wing_index == -1 or editing_ship_index == -1:
		print("Something went wrong!")
	elif weapon_name != MissionData.wing_loadouts[editing_wing_index][editing_ship_index].missile_weapons[slot_index].name:
		MissionData.wing_loadouts[editing_wing_index][editing_ship_index].missile_weapons[slot_index].model = missile_weapon_resources[weapon_name].model
		MissionData.wing_loadouts[editing_wing_index][editing_ship_index].missile_weapons[slot_index].name = weapon_name


func _on_wing_checkbox_pressed(selected_index: int):
	for index in range(wing_containers.size()):
		if index == selected_index:
			wing_containers[index].show()
		else:
			wing_containers[index].hide()


func _on_wing_icon_pressed(ship_class: String):
	if editing_wing_index == -1 or editing_ship_index == -1:
		print("Something went wrong!")
	elif ship_class != MissionData.wing_loadouts[editing_wing_index][editing_ship_index].ship_class:
		MissionData.wing_loadouts[editing_wing_index][editing_ship_index].ship_class = ship_class
		MissionData.wing_loadouts[editing_wing_index][editing_ship_index].model = ship_resources[ship_class].model

		_set_editing_ship(ship_class, editing_wing_index, editing_ship_index)


func _on_wing_selection_pressed(wing_index: int, ship_index: int):
	_set_editing_ship(MissionData.wing_loadouts[wing_index][ship_index].ship_class, wing_index, ship_index)


func _set_editing_ship(ship_class: String, wing_index: int, ship_index: int):
	var wing_name: String = MissionData.wing_names[wing_index]
	var ship_name: String = wing_name + " " + str(ship_index + 1)

	_update_ship_preview(ship_class)
	ship_overhead.set_texture(ship_resources[ship_class].overhead)
	ship_wing_name.set_text(ship_name)

	# Update weapon slot icons
	var ship_loadout = MissionData.wing_loadouts[wing_index][ship_index]
	for index in range(energy_weapon_slots.size()):
		if index < MissionData.ship_data[ship_loadout.ship_class].energy_weapon_slots:
			energy_weapon_slots[index].show()

			var energy_weapon_name = ship_loadout.energy_weapons[index].name
			if energy_weapon_name == "none":
				energy_weapon_slots[index].hide_current_icon()
			else:
				energy_weapon_slots[index].set_current_icon(energy_weapon_resources[energy_weapon_name].icon)
		else:
			energy_weapon_slots[index].hide()

	for index in range(missile_weapon_slots.size()):
		if index < MissionData.ship_data[ship_loadout.ship_class].missile_weapon_slots:
			missile_weapon_slots[index].show()

			var missile_weapon_name = ship_loadout.missile_weapons[index].name
			if missile_weapon_name == "none":
				missile_weapon_slots[index].hide_current_icon()
			else:
				missile_weapon_slots[index].set_current_icon(missile_weapon_resources[missile_weapon_name].icon)
		else:
			missile_weapon_slots[index].hide()

	if editing_ship_index != -1:
		wing_containers[editing_wing_index].get_child(editing_ship_index).toggle_border(false)

	var ship_icon = wing_containers[wing_index].get_child(ship_index)
	ship_icon.toggle_border(true)

	editing_wing_index = wing_index
	editing_ship_index = ship_index

	ship_overhead.show()
	weapon_slots_rows.show()


func _update_ship_preview(ship_class: String):
	if ship_class != current_ship_class:
		current_ship_class = ship_class

		ship_preview_container.show()

		var ship_instance = ship_resources[current_ship_class].model.instance()
		ship_preview_container.set_ship(current_ship_class, MissionData.ship_data[current_ship_class], ship_instance)

		return true

	return false


func _update_weapon_preview(weapon_type: String, weapon_name: String):
	var data
	var video_stream

	match weapon_type:
		"energy_weapon":
			data = MissionData.energy_weapon_data[weapon_name]
			video_stream = energy_weapon_resources[weapon_name].video
		"missile_weapon":
			data = MissionData.missile_weapon_data[weapon_name]
			video_stream = missile_weapon_resources[weapon_name].video

	if data != null:
		weapon_preview_container.set_weapon(weapon_name, data, video_stream)


const ShipBase = preload("ShipBase.gd")
const ShipSlot = preload("ShipSlot.gd")
const WeaponBase = preload("WeaponBase.gd")
const WeaponSlot = preload("WeaponSlot.gd")

const LOADOUT_ICON = preload("res://prefabs/loadout_icon.tscn")
