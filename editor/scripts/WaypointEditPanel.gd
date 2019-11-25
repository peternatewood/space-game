extends Control

onready var waypoint_group_options = get_node("Waypoint Edit Rows/Waypoint Group Options")
onready var waypoint_rows = get_node("Waypoint Edit Rows/Waypoints Scroll/Waypoint Rows")


func _ready():
	var close_button = get_node("Waypoint Edit Rows/Title Columns/Close Button")
	close_button.connect("pressed", self, "hide")

	var update_button = get_node("Waypoint Edit Rows/Update Button")
	update_button.connect("pressed", self, "_on_update_pressed")


func _on_update_pressed():
	emit_signal("update_pressed")


# PUBLIC


func populate_rows(waypoints: Array, waypoint_groups: Array):
	for waypoint in waypoints:
		var waypoint_edit = WAYPOINT_EDIT.instance()
		waypoint_rows.add_child(waypoint_edit)
		waypoint_edit.assign_waypoint(waypoint)

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
			waypoint_group_options.remove_item(index)



const WAYPOINT_EDIT = preload("res://editor/prefabs/waypoint_edit.tscn")

signal update_pressed
