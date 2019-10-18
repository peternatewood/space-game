extends Control

onready var ship_class_label = get_node("Ship Preview Container/Ship Details/Ship Class")
onready var ship_overhead = get_node("Ship Overhead")
onready var ship_preview = get_node("Ship Preview Viewport")
onready var ship_preview_container = get_node("Ship Preview Container")
onready var ship_selection_container = get_node("Left Rows/Ships Panel/Ship Selection Container")
onready var wing_ships_container = get_node("Wing Ships Container")

var current_ship_class: String
var editing_ship_index: int = 0
var editing_wing_index: int = 0
var mouse_over_wing_ship: bool = false
var ship_data: Dictionary = {}
var wing_ship_over
var wing_containers
# TODO: get this default data on a per mission basis
var wings: Array = [
	[
		{ "ship_class": "Spider Fighter", "energy_weapons": [ "Energy Bolt", "Energy Bolt" ], "missile_weapons": [ "Heak Seeker", "Heat Seeker" ] },
		{ "ship_class": "Spider Fighter", "energy_weapons": [ "Energy Bolt", "Energy Bolt" ], "missile_weapons": [ "Heak Seeker", "Heat Seeker" ] },
		{ "ship_class": "Spider Fighter", "energy_weapons": [ "Energy Bolt", "Energy Bolt" ], "missile_weapons": [ "Heak Seeker", "Heat Seeker" ] }
	],
	[
		{ "ship_class": "Frog Fighter", "energy_weapons": [ "Energy Bolt", "Energy Bolt" ], "missile_weapons": [ "Heak Seeker" ] }
	]
]


func _ready():
	for dir in SHIP_DIRECTORIES:
		var model = load("res://models/" + dir + "/" + dir + ".dae")
		if model != null:
			var ship_instance = model.instance()
			var ship_class = ship_instance.get_meta("ship_class")

			var icon = ImageTexture.new()
			var icon_load_error = icon.load("res://models/" + dir + "/overhead.png")
			if icon_load_error != OK:
				print("Error loading ship icon: " + str(icon_load_error))

			var overhead = ImageTexture.new()
			var overhead_load_error = overhead.load("res://models/" + dir + "/loadout_overhead.png")
			if overhead_load_error != OK:
				print("Error loading overhead icon: " + str(overhead_load_error))

			var loadout_icon = SHIP_LOADOUT_ICON.instance()
			ship_selection_container.add_child(loadout_icon)
			loadout_icon.set_ship(ship_class, icon)
			loadout_icon.connect("icon_clicked", self, "_on_loadout_icon_clicked")
			loadout_icon.connect("draggable_icon_dropped", self, "_on_draggable_icon_dropped")

			ship_data[ship_class] = { "model": model, "icon": icon, "overhead": overhead }

	wing_containers = wing_ships_container.get_children()
	# Set wing ship icons based on wing defaults
	var wing_index: int = 0
	for wing in wing_containers:
		var ship_icons = wing.get_children()
		for ship_index in range(4):
			if ship_index < wings[wing_index].size():
				var ship_class = wings[wing_index][ship_index].ship_class
				ship_icons[ship_index].set_icon(ship_data[ship_class].icon)
				ship_icons[ship_index].set_indexes(wing_index, ship_index)
				ship_icons[ship_index].connect("pressed", self, "_on_wing_icon_pressed", [ wing_index, ship_index ])
			else:
				ship_icons[ship_index].disable()
		wing_index += 1

	var index: int = 0
	for node in get_node("Left Rows/Wings Panel/Wing Selection Container").get_children():
		if node is CheckBox:
			node.connect("pressed", self, "_on_wing_checkbox_pressed", [ index ])
			index += 1


func _on_draggable_icon_dropped(icon, over_area):
	if over_area is WingShipIcon:
		over_area.set_icon(icon.get_texture())
		over_area.highlight(false)
		# Set current wing ship selection to icon we dropped over
		_set_editing_ship(icon.ship_class, over_area.wing_index, over_area.ship_index)


func _on_loadout_icon_clicked(icon):
	_update_ship_preview(icon.ship_class)


func _on_wing_checkbox_pressed(index: int):
	for wing_index in range(wing_containers.size()):
		wing_containers[wing_index].toggle(wing_index == index)


func _on_wing_icon_pressed(wing_index: int, ship_index: int):
	_set_editing_ship(wings[wing_index][ship_index].ship_class, wing_index, ship_index)


func _set_editing_ship(ship_class: String, wing_index: int, ship_index: int):
	_update_ship_preview(ship_class)
	ship_overhead.set_texture(ship_data[ship_class].overhead)
	wings[wing_index][ship_index].ship_class = ship_class


func _update_ship_preview(ship_class: String):
	if ship_class != current_ship_class:
		current_ship_class = ship_class

		ship_preview_container.show()
		ship_class_label.set_text(current_ship_class)
		ship_preview.show_ship(ship_data[current_ship_class].model)

		return true

	return false


const WingShipIcon = preload("WingShipIcon.gd")

const SHIP_DIRECTORIES: Array = [ "fighter_frog", "fighter_hawk", "fighter_spider" ]
const SHIP_LOADOUT_ICON = preload("res://icons/ship_loadout_icon.tscn")
