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
	var current_group_count = group_rows.get_child_count()
	var new_group_count = group_names.size()

	for index in range(max(new_group_count, current_group_count)):
		if index >= current_group_count:
			# Add lineedits
			var group_line_edit = LineEdit.new()
			group_rows.add_child(group_line_edit)

			group_line_edit.set_h_size_flags(SIZE_EXPAND_FILL)
			group_line_edit.set_text(group_names[index])
		else:
			if index >= new_group_count:
				# Remove old Lineedits
				group_rows.get_child(new_group_count).queue_free()
			else:
				# Update existing lineedit
				var group_line_edit = group_rows.get_child(index)
				group_line_edit.set_text(group_names[index])

