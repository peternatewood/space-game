extends AcceptDialog

onready var ship_options = get_node("Add Ship Rows/Add Ship Grid/Ship Options")
onready var name_lineedit = get_node("Add Ship Rows/Add Ship Grid/Name LineEdit")
onready var warning_label = get_node("Add Ship Rows/Warnings Label")


func populate_ship_options(attack_ship_names: Array):
	var ship_index: int = 0
	for ship_name in attack_ship_names:
		ship_options.add_item(ship_name, ship_index)
		ship_index += 1


func set_warning_text(text: String = "", show_warning: bool = true):
	warning_label.set_text(text)

	if show_warning:
		warning_label.show()
	else:
		warning_label.hide()
