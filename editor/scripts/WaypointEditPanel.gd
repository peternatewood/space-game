extends Control

onready var waypoint_rows = get_node("Waypoint Edit Rows/Waypoints Scroll/Waypoint Rows")


func _ready():
	var close_button = get_node("Waypoint Edit Rows/Title Columns/Close Button")
	close_button.connect("pressed", self, "hide")

	var update_button = get_node("Waypoint Edit Rows/Update Button")
	update_button.connect("pressed", self, "_on_update_pressed")


func _on_update_pressed():
	emit_signal("update_pressed")


# PUBLIC


func populate_rows(waypoints: Array):
	for waypoint in waypoints:
		var waypoint_edit = WAYPOINT_EDIT.instance()
		waypoint_rows.add_child(waypoint_edit)
		waypoint_edit.assign_waypoint(waypoint)


const WAYPOINT_EDIT = preload("res://editor/prefabs/waypoint_edit.tscn")

signal update_pressed
