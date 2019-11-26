extends Control

onready var waypoint_group_options = get_node("Waypoint Edit Rows/Waypoint Group Options")
onready var waypoint_rows = get_node("Waypoint Edit Rows/Waypoints Scroll/Waypoint Rows")


func _ready():
	var close_button = get_node("Waypoint Edit Rows/Title Columns/Close Button")
	close_button.connect("pressed", self, "hide")

	waypoint_group_options.connect("item_selected", self, "_on_waypoint_group_selected")

	var add_button = get_node("Waypoint Edit Rows/Add Button")
	add_button.connect("pressed", self, "_on_add_pressed")

	var update_button = get_node("Waypoint Edit Rows/Update Button")
	update_button.connect("pressed", self, "_on_update_pressed")


func _on_add_pressed():
	emit_signal("add_pressed")


func _on_update_pressed():
	emit_signal("update_pressed")


func _on_waypoint_group_selected(item_index: int):
	var selected_group_name: String = get_selected_group_name()

	for waypoint_edit in waypoint_rows.get_children():
		if waypoint_edit.waypoint_node.is_in_group(selected_group_name):
			waypoint_edit.show()
		else:
			waypoint_edit.hide()


# PUBLIC


func add_waypoint(waypoint_node):
	var waypoint_edit = WAYPOINT_EDIT.instance()
	waypoint_rows.add_child(waypoint_edit)
	waypoint_edit.assign_waypoint(waypoint_node)


func get_selected_group_name():
	var selected_index: int = waypoint_group_options.get_selected_id()

	return waypoint_group_options.get_item_text(selected_index)


func populate_rows(waypoints: Array, waypoint_groups: Array):
	populate_waypoint_group_options(waypoint_groups)

	var selected_group_name: String = get_selected_group_name()

	var new_waypoints_count: int = waypoints.size()
	var current_waypoints_count: int = waypoint_rows.get_child_count()

	for index in range(max(current_waypoints_count, new_waypoints_count)):
		if index >= current_waypoints_count:
			# Add edit controls
			var waypoint_edit = WAYPOINT_EDIT.instance()
			waypoint_rows.add_child(waypoint_edit)
			waypoint_edit.assign_waypoint(waypoints[index])

			if not waypoints[index].is_in_group(selected_group_name):
				waypoint_edit.hide()
		else:
			# Update existing edit controls
			var waypoint_edit = waypoint_rows.get_child(index)
			waypoint_edit.assign_waypoint(waypoints[index])

			if waypoint_edit.waypoint_node.is_in_group(selected_group_name):
				waypoint_edit.show()
			else:
				waypoint_edit.hide()

		if index >= new_waypoints_count:
			# Remove old options
			waypoint_rows.remove_child(new_waypoints_count)


func populate_waypoint_group_options(waypoint_groups: Array):
	var new_group_count: int = waypoint_groups.size()
	var current_group_count: int = waypoint_group_options.get_item_count()

	for index in range(max(new_group_count, current_group_count)):
		if index >= current_group_count:
			# Add options
			waypoint_group_options.add_item(waypoint_groups[index], index)
		else:
			# Update current item text
			waypoint_group_options.set_item_text(index, waypoint_groups[index])

		if index >= new_group_count:
			# Remove old options
			waypoint_group_options.remove_item(new_group_count)


func select_group_name(group_name: String):
	for index in range(waypoint_group_options.get_item_count()):
		if waypoint_group_options.get_item_text(index) == group_name:
			waypoint_group_options.select(index)
			_on_waypoint_group_selected(index)
			return true

	return false


const WAYPOINT_EDIT = preload("res://editor/prefabs/waypoint_edit.tscn")

signal add_pressed
signal update_pressed
