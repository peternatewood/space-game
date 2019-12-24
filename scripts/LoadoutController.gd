extends Control

onready var draggable_icon = get_node("Draggable Icon")
onready var energy_weapon_slots = get_node("Weapon Slots Rows/Energy Weapon Rows").get_children()
onready var missile_weapon_slots = get_node("Weapon Slots Rows/Missile Weapon Rows").get_children()
onready var mission_data = get_node("/root/MissionData")
onready var ship_class_label = get_node("Ship Preview Container/Ship Details/Ship Class")
onready var ship_hull_label = get_node("Ship Preview Container/Ship Details/Hull Strength")
onready var ship_overhead = get_node("Ship Overhead")
onready var ship_preview = get_node("Ship Preview Viewport")
onready var ship_preview_container = get_node("Ship Preview Container")
onready var ship_shield_label = get_node("Ship Preview Container/Ship Details/Shield Strength")
onready var ship_speed_label = get_node("Ship Preview Container/Ship Details/Ship Speed")
onready var ship_energy_slots_label = get_node("Ship Preview Container/Ship Details/Energy Weapon Slots")
onready var ship_missile_slots_label = get_node("Ship Preview Container/Ship Details/Missile Weapon Slots")
onready var ship_weapon_capacity_label = get_node("Ship Preview Container/Ship Details/Weapon Capacity")
onready var ship_wing_name = get_node("Weapon Slots Rows/Ship Wing Name")
onready var weapon_slots_rows = get_node("Weapon Slots Rows")
onready var weapon_preview = get_node("Weapon Preview Container")
onready var wing_containers = get_node("Wing Ships Container").get_children()

var current_ship_class: String
var editing_ship_index: int = -1
var editing_wing_index: int = -1
var energy_weapon_data: Dictionary = {}
var missile_weapon_data: Dictionary = {}
var ship_data: Dictionary = {}
var wing_ship_over


func _ready():
	var ship_selection_container = get_node("Left Rows/Ships Panel/Ship Selection Container")
	for section in mission_data.ship_data.keys():
		var ship_class = mission_data.ship_data[section].get("ship_class", "")

		if mission_data.armory.ships.has(ship_class):
			var model = load(mission_data.ship_data[section].model_path)
			var ship_instance = model.instance()
			var source_folder = ship_instance.get_meta("source_folder")
			var energy_weapon_slot_count = ship_instance.get_node("Energy Weapon Groups").get_child_count()
			var missile_weapon_slot_count = ship_instance.get_node("Missile Weapon Groups").get_child_count()

			var icon = ImageTexture.new()
			var icon_stream_texture = load(source_folder + "/icon.png")
			var icon_texture = icon_stream_texture.get_data()
			icon.create_from_image(icon_texture, 0)

			var overhead = ImageTexture.new()
			var overhead_stream_texture = load(source_folder + "/loadout_overhead.png")
			var overhead_texture = overhead_stream_texture.get_data()
			overhead.create_from_image(overhead_texture, 0)

			var radial_icon = RADIAL_ICON.instance()
			ship_selection_container.add_child(radial_icon)
			radial_icon.set_normal_texture(icon)
			radial_icon.set_h_size_flags(SIZE_SHRINK_CENTER)
			radial_icon.connect("pressed", self, "_update_ship_preview", [ ship_class ])

			ship_data[ship_class] = {
				"model": model,
				"icon": icon,
				"overhead": overhead,
				"max_speed": ship_instance.get_meta("max_speed"),
				"hull_hitpoints": ship_instance.get_meta("hull_hitpoints"),
				"shield_hitpoints": ship_instance.get_meta("shield_hitpoints"),
				"energy_weapon_slots": energy_weapon_slot_count,
				"missile_weapon_slots": missile_weapon_slot_count,
				"missile_capacity": ship_instance.get_meta("missile_capacity")
			}

	var energy_weapons_container = get_node("Left Rows/Energy Weapons Panel/Energy Weapons Container")
	for energy_weapon_name in mission_data.energy_weapon_data.keys():
		if mission_data.armory.energy_weapons.has(energy_weapon_name):
			var model = load(mission_data.energy_weapon_data[energy_weapon_name].model_path)
			var energy_weapon_instance = model.instance()
			var source_folder = energy_weapon_instance.get_meta("source_folder")

			var icon = ImageTexture.new()
			var icon_stream_texture = load(source_folder + "/icon.png")
			var icon_texture = icon_stream_texture.get_data()
			icon.create_from_image(icon_texture, 0)

			var energy_weapon_icon = RADIAL_ICON.instance()
			energy_weapons_container.add_child(energy_weapon_icon)
			energy_weapon_icon.set_normal_texture(icon)
			energy_weapon_icon.set_h_size_flags(SIZE_SHRINK_CENTER)
			energy_weapon_icon.connect("pressed", self, "_update_weapon_preview", [ "energy_weapon", energy_weapon_name ])

			var energy_weapon_video = load(source_folder + "/video.ogv")

			energy_weapon_data[energy_weapon_name] = {
				"cost": energy_weapon_instance.cost,
				"fire_delay": energy_weapon_instance.fire_delay,
				"hull_damage": WeaponBase.get_damage_strength(energy_weapon_instance.damage_hull),
				"icon": icon,
				"model": model,
				"shield_damage": WeaponBase.get_damage_strength(energy_weapon_instance.damage_shield),
				"video": energy_weapon_video
			}

	for index in range(energy_weapon_slots.size()):
		energy_weapon_slots[index].set_options(energy_weapon_data)
		energy_weapon_slots[index].connect("icon_pressed", self, "_on_energy_weapon_slot_pressed", [ index ])

	var missile_weapons_container = get_node("Left Rows/Missile Weapons Panel/Missile Weapons Container")
	for missile_weapon_name in mission_data.missile_weapon_data.keys():
		if mission_data.armory.missile_weapons.has(missile_weapon_name):
			var model = load(mission_data.missile_weapon_data[missile_weapon_name].model_path)
			var missile_weapon_instance = model.instance()
			var source_folder = missile_weapon_instance.get_meta("source_folder")

			var icon = ImageTexture.new()
			var icon_stream_texture = load(source_folder + "/icon.png")
			var icon_texture = icon_stream_texture.get_data()
			icon.create_from_image(icon_texture, 0)

			var missile_weapon_icon = RADIAL_ICON.instance()
			missile_weapons_container.add_child(missile_weapon_icon)
			missile_weapon_icon.set_normal_texture(icon)
			missile_weapon_icon.set_h_size_flags(SIZE_SHRINK_CENTER)
			missile_weapon_icon.connect("pressed", self, "_update_weapon_preview", [ "missile_weapon", missile_weapon_name ])

			var missile_weapon_video = load(source_folder + "/video.ogv")

			missile_weapon_data[missile_weapon_name] = {
				"fire_delay": missile_weapon_instance.fire_delay,
				"hull_damage": WeaponBase.get_damage_strength(missile_weapon_instance.damage_hull),
				"icon": icon,
				"model": model,
				"shield_damage": WeaponBase.get_damage_strength(missile_weapon_instance.damage_shield),
				"weight": WeaponBase.get_ammo_cost_description(missile_weapon_instance.ammo_cost),
				"video": missile_weapon_video
			}

	for index in range(missile_weapon_slots.size()):
		missile_weapon_slots[index].set_options(missile_weapon_data)
		missile_weapon_slots[index].connect("icon_pressed", self, "_on_missile_weapon_slot_pressed", [ index ])

	# Create wing checkboxes
	var wing_selection_checkboxes = get_node("Left Rows/Wings Panel/Wing Selection Container").get_children()
	var wing_index: int = 0

	for index in range(wing_selection_checkboxes.size()):
		var checkbox = wing_selection_checkboxes[index]
		var wing_name = mission_data.wing_names[index]

		if wing_name == "":
			checkbox.hide()
		else:
			checkbox.set_text(mission_data.wing_names[index])
			checkbox.connect("pressed", self, "_on_wing_checkbox_pressed", [ index ])

	# Set wing ship icons based on wing defaults
	var wing_count: int = mission_data.wing_loadouts.size()
	for wing_index in range(wing_containers.size()):
		if wing_index < wing_count:
			var ship_count: int = mission_data.wing_loadouts[wing_index].size()

			for ship_index in range(4):
				if ship_index < ship_count:
					var ship_class: String = mission_data.wing_loadouts[wing_index][ship_index].get("ship_class", "")

					wing_containers[wing_index].get_child(ship_index).set_options(ship_data)
					wing_containers[wing_index].get_child(ship_index).set_current_icon(ship_data[ship_class].icon)
					wing_containers[wing_index].get_child(ship_index).connect("radial_pressed", self, "_on_wing_radial_pressed", [ wing_index, ship_index ])
					wing_containers[wing_index].get_child(ship_index).connect("icon_pressed", self, "_on_wing_icon_pressed")
				else:
					wing_containers[wing_index].get_child(ship_index).disable()
		else:
			wing_containers[wing_index].hide()

	# Default to showing player/Alpha 1 loadout
	_on_wing_radial_pressed(0, 0)


func _on_energy_weapon_slot_pressed(weapon_name: String, slot_index: int):
	if editing_wing_index == -1 or editing_ship_index == -1:
		print("Something went wrong!")
	elif weapon_name != mission_data.wing_loadouts[editing_wing_index][editing_ship_index].energy_weapons[slot_index].name:
		mission_data.wing_loadouts[editing_wing_index][editing_ship_index].energy_weapons[slot_index].model = energy_weapon_data[weapon_name].model
		mission_data.wing_loadouts[editing_wing_index][editing_ship_index].energy_weapons[slot_index].name = weapon_name


func _on_missile_weapon_slot_pressed(weapon_name: String, slot_index: int):
	if editing_wing_index == -1 or editing_ship_index == -1:
		print("Something went wrong!")
	elif weapon_name != mission_data.wing_loadouts[editing_wing_index][editing_ship_index].missile_weapons[slot_index].name:
		mission_data.wing_loadouts[editing_wing_index][editing_ship_index].missile_weapons[slot_index].model = missile_weapon_data[weapon_name].model
		mission_data.wing_loadouts[editing_wing_index][editing_ship_index].missile_weapons[slot_index].name = weapon_name


func _on_wing_checkbox_pressed(selected_index: int):
	for index in range(wing_containers.size()):
		if index == selected_index:
			wing_containers[index].show()
		else:
			wing_containers[index].hide()


func _on_wing_icon_pressed(ship_class: String):
	if editing_wing_index == -1 or editing_ship_index == -1:
		print("Something went wrong!")
	elif ship_class != mission_data.wing_loadouts[editing_wing_index][editing_ship_index].ship_class:
		mission_data.wing_loadouts[editing_wing_index][editing_ship_index].ship_class = ship_class
		mission_data.wing_loadouts[editing_wing_index][editing_ship_index].model = ship_data[ship_class].model

		_set_editing_ship(ship_class, editing_wing_index, editing_ship_index)


func _on_wing_radial_pressed(wing_index: int, ship_index: int):
	_set_editing_ship(mission_data.wing_loadouts[wing_index][ship_index].ship_class, wing_index, ship_index)


func _set_editing_ship(ship_class: String, wing_index: int, ship_index: int):
	var wing_name: String = mission_data.wing_names[wing_index]

	_update_ship_preview(ship_class)
	ship_overhead.set_texture(ship_data[ship_class].overhead)
	ship_wing_name.set_text(wing_name + " " + str(ship_index + 1))

	# Update weapon slot icons
	var ship_loadout = mission_data.wing_loadouts[wing_index][ship_index]
	for index in range(energy_weapon_slots.size()):
		if index < ship_data[ship_loadout.ship_class].energy_weapon_slots:
			energy_weapon_slots[index].show()

			var energy_weapon_name = ship_loadout.energy_weapons[index].name
			if energy_weapon_name == "none":
				energy_weapon_slots[index].hide_current_icon()
			else:
				energy_weapon_slots[index].set_current_icon(energy_weapon_data[energy_weapon_name].icon)
		else:
			energy_weapon_slots[index].hide()

	for index in range(missile_weapon_slots.size()):
		if index < ship_data[ship_loadout.ship_class].missile_weapon_slots:
			missile_weapon_slots[index].show()

			var missile_weapon_name = ship_loadout.missile_weapons[index].name
			if missile_weapon_name == "none":
				missile_weapon_slots[index].hide_current_icon()
			else:
				missile_weapon_slots[index].set_current_icon(missile_weapon_data[missile_weapon_name].icon)
		else:
			missile_weapon_slots[index].hide()

	if editing_ship_index != -1:
		wing_containers[editing_wing_index].get_child(editing_ship_index).toggle_border(false)

	wing_containers[wing_index].get_child(ship_index).toggle_border(true)

	editing_wing_index = wing_index
	editing_ship_index = ship_index

	ship_overhead.show()
	weapon_slots_rows.show()


func _update_ship_preview(ship_class: String):
	if ship_class != current_ship_class:
		current_ship_class = ship_class

		ship_preview_container.show()
		ship_class_label.set_text(current_ship_class)
		ship_hull_label.set_text(ShipBase.get_hitpoints_strength(ship_data[current_ship_class].hull_hitpoints))
		ship_shield_label.set_text(ShipBase.get_hitpoints_strength(ship_data[current_ship_class].shield_hitpoints))
		ship_speed_label.set_text(str(10 * ship_data[current_ship_class].max_speed) + " m/s")
		ship_energy_slots_label.set_text(str(ship_data[current_ship_class].energy_weapon_slots))
		ship_missile_slots_label.set_text(str(ship_data[current_ship_class].missile_weapon_slots))
		ship_weapon_capacity_label.set_text(ShipBase.get_weapon_capacity_level(ship_data[current_ship_class].missile_capacity))
		ship_preview.show_ship(ship_data[current_ship_class].model)

		return true

	return false


func _update_weapon_preview(weapon_type: String, weapon_name: String):
	var data

	match weapon_type:
		"energy_weapon":
			data = energy_weapon_data[weapon_name]
		"missile_weapon":
			data = missile_weapon_data[weapon_name]

	if data != null:
		weapon_preview.set_weapon(weapon_type, weapon_name, data)


const ShipBase = preload("ShipBase.gd")
const ShipSlot = preload("ShipSlot.gd")
const WeaponBase = preload("WeaponBase.gd")
const WeaponSlot = preload("WeaponSlot.gd")

const RADIAL_ICON = preload("res://prefabs/radial_icon.tscn")
