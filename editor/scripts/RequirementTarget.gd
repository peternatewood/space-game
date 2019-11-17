extends Control

onready var options = get_node("Options")


func _ready():
	get_node("Delete Button").connect("pressed", self, "_on_delete_pressed")
	options.connect("item_selected", self, "_on_options_item_selected")


func _on_delete_pressed():
	emit_signal("delete_button_pressed")
	queue_free()


func _on_options_item_selected(item_index: int):
	emit_signal("options_item_selected", item_index)


# PUBLIC


func get_name():
	return options.get_item_text(options.get_selected_id())


func populate_options(ship_names: Array):
	var ship_index: int = 0
	var ship_count: int = options.get_item_count()
	for ship_name in ship_names:
		if ship_index < ship_count:
			options.set_item_text(ship_index, ship_name)
		else:
			options.add_item(ship_name, ship_index)

		ship_index += 1

	for index in range(ship_names.size(), ship_count):
		options.remove_item(index)


func select_name(name: String = ""):
	if name != "":
		for index in range(options.get_item_count()):
			if options.get_item_text(index) == name:
				options.select(index)
				break


signal delete_button_pressed
signal options_item_selected
