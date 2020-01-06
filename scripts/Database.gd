extends Control

onready var mission_data = get_node("/root/MissionData")
onready var preview_viewport = get_node("Ship Preview Viewport")
onready var ship_label = get_node("Tabs/Ships/Ships Columns/Ship Preview Rows/Ship Preview Label")
onready var ship_list = get_node("Tabs/Ships/Ships Columns/Ship List")


func _ready():
	for ship_name in mission_data.ship_data.keys():
		var ship_button = Button.new()
		ship_list.add_child(ship_button)

		ship_button.set_text(ship_name)
		ship_button.connect("pressed", self, "_on_ship_button_pressed", [ ship_name ])


func _on_ship_button_pressed(ship_name: String):
	var ship_model = load(mission_data.ship_data[ship_name].model_path)
	var ship_instance = ship_model.instance()
	ship_instance.set_script(ShipBase)

	preview_viewport.set_ship(ship_instance)

	ship_label.set_text(ship_name)


const ShipBase = preload("ShipBase.gd")
