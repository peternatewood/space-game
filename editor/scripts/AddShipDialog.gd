extends AcceptDialog

onready var attack_ship_options = get_node("Add Ship Rows/Add Ship Grid/Attack Ship Options")
onready var capital_ship_options = get_node("Add Ship Rows/Add Ship Grid/Capital Ship Options")
onready var name_lineedit = get_node("Add Ship Rows/Add Ship Grid/Name LineEdit")
onready var ship_category_options = get_node("Add Ship Rows/Ship Category Options")
onready var warning_label = get_node("Add Ship Rows/Warnings Label")


func _ready():
	ship_category_options.connect("item_selected", self, "_on_ship_category_changed")


func _on_ship_category_changed(item_id: int):
	match item_id:
		0:
			attack_ship_options.show()
			capital_ship_options.hide()
		1:
			attack_ship_options.hide()
			capital_ship_options.show()


# PUBLIC


func populate_ship_options(attack_ship_names: Array, capital_ship_names: Array):
	var ship_index: int = 0
	for ship_name in attack_ship_names:
		attack_ship_options.add_item(ship_name, ship_index)
		ship_index += 1

	ship_index = 0
	for ship_name in capital_ship_names:
		capital_ship_options.add_item(ship_name, ship_index)
		ship_index += 1


func set_warning_text(text: String = "", show_warning: bool = true):
	warning_label.set_text(text)

	if show_warning:
		warning_label.show()
	else:
		warning_label.hide()
