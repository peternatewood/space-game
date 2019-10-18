extends Control

onready var ship_class = get_node("Ship Preview Container/Ship Details/Ship Class")
onready var ship_preview = get_node("Ship Preview Viewport")
onready var ship_preview_container = get_node("Ship Preview Container")
onready var ship_selection_container = get_node("Left Rows/PanelContainer/Ship Selection Container")


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

			var loadout_icon = SHIP_LOADOUT_ICON.instance()
			ship_selection_container.add_child(loadout_icon)
			loadout_icon.set_ship(ship_class, icon, model)
			loadout_icon.connect("icon_clicked", self, "_on_loadout_icon_clicked")


func _on_loadout_icon_clicked(icon):
	ship_preview_container.show()

	ship_class.set_text(icon.ship_name.text)
	ship_preview.show_ship(icon.model)


const SHIP_DIRECTORIES: Array = [ "fighter_frog", "fighter_hawk", "fighter_spider" ]
const SHIP_LOADOUT_ICON = preload("res://icons/ship_loadout_icon.tscn")
