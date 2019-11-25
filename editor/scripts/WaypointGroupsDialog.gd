extends AcceptDialog

onready var group_rows = get_node("Waypoint Group Rows/Waypoint Group Scroll/Waypoint Group Lineedits")


func _ready():
	var add_group_button = get_node("Waypoint Group Rows/Add Group Button")
	add_group_button.connect("pressed", self, "_on_add_group_pressed")


func _on_add_group_pressed():
	var group_line_edit = LineEdit.new()
	group_rows.add_child(group_line_edit)
	group_line_edit.set_h_size_flags(SIZE_EXPAND_FILL)


# PUBLIC


func get_group_names():
	var group_names: Array = []

	for lineedit in group_rows.get_children():
		if lineedit.text != "":
			group_names.append(lineedit.text)

	return group_names


func populate_row_options(group_names: Array):
	for group_name in group_names:
		var group_line_edit = LineEdit.new()
		group_rows.add_child(group_line_edit)

		group_line_edit.set_h_size_flags(SIZE_EXPAND_FILL)
		group_line_edit.set_text(group_name)
