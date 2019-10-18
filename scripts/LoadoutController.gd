extends Control

onready var ship_class = get_node("Ship Preview Container/Ship Details/Ship Class")
onready var ship_preview = get_node("Ship Preview Viewport")
onready var ship_preview_container = get_node("Ship Preview Container")
onready var ship_selection_container = get_node("Left Rows/PanelContainer/Ship Selection Container")

var current_ship_class: String
var ship_data: Dictionary = {}


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

			ship_data[ship_class] = { "model": model, "icon": icon, "overhead": overhead }


func _on_loadout_icon_clicked(icon):
	if icon.ship_class != current_ship_class:
		ship_preview_container.show()

		current_ship_class = icon.ship_class
		ship_class.set_text(icon.ship_class)
		ship_preview.show_ship(ship_data[icon.ship_class].model)


const SHIP_DIRECTORIES: Array = [ "fighter_frog", "fighter_hawk", "fighter_spider" ]
const SHIP_LOADOUT_ICON = preload("res://icons/ship_loadout_icon.tscn")
