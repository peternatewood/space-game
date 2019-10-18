extends Control

onready var ship_class = get_node("Ship Preview Container/Ship Details/Ship Class")
onready var ship_preview = get_node("Ship Preview Viewport")
onready var ship_preview_container = get_node("Ship Preview Container")
onready var ship_selection_container = get_node("Left Rows/Ships Panel/Ship Selection Container")
onready var wing_ships_container = get_node("Wing Ships Container")

var current_ship_class: String
var mouse_over_wing_ship: bool = false
var ship_data: Dictionary = {}
var wing_ship_over
var wing_containers


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
	var index: int = 0
	for node in get_node("Left Rows/Wings Panel/Wing Selection Container").get_children():
		if node is CheckBox:
			node.connect("pressed", self, "_on_wing_checkbox_pressed", [ index ])
			index += 1


func _on_draggable_icon_dropped(icon, over_area):
	if over_area is WingShipIcon:
		over_area.set_icon(icon.get_texture())
		over_area.highlight(false)


func _on_loadout_icon_clicked(icon):
	if icon.ship_class != current_ship_class:
		ship_preview_container.show()

		current_ship_class = icon.ship_class
		ship_class.set_text(icon.ship_class)
		ship_preview.show_ship(ship_data[icon.ship_class].model)


func _on_wing_checkbox_pressed(index: int):
	for wing_index in range(wing_containers.size()):
		wing_containers[wing_index].toggle(wing_index == index)


const WingShipIcon = preload("WingShipIcon.gd")

const SHIP_DIRECTORIES: Array = [ "fighter_frog", "fighter_hawk", "fighter_spider" ]
const SHIP_LOADOUT_ICON = preload("res://icons/ship_loadout_icon.tscn")
