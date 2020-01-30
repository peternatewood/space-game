extends Control

onready var name_label = get_node("Waypoint Name")
onready var pos_x_spinbox = get_node("Position X SpinBox")
onready var pos_y_spinbox = get_node("Position Y SpinBox")
onready var pos_z_spinbox = get_node("Position Z SpinBox")

var waypoint_node


func _ready():
	name_label.connect("text_changed", self, "_on_name_lineedit_changed")

	pos_x_spinbox.connect("value_changed", self, "_on_x_spinbox_changed")
	pos_y_spinbox.connect("value_changed", self, "_on_y_spinbox_changed")
	pos_z_spinbox.connect("value_changed", self, "_on_z_spinbox_changed")

	var delete_button = get_node("Delete Button")
	delete_button.connect("pressed", self, "_on_delete_pressed")


func _on_delete_pressed():
	waypoint_node.free()
	emit_signal("delete_pressed")
	queue_free()


func _on_name_lineedit_changed(new_text: String):
	emit_signal("name_changed", new_text)


func _on_waypoint_tree_exiting():
	queue_free()


func _on_waypoint_renamed():
	name_label.set_text(waypoint_node.name)


func _on_x_spinbox_changed(new_value: float):
	waypoint_node.transform.origin.x = new_value


func _on_y_spinbox_changed(new_value: float):
	waypoint_node.transform.origin.y = new_value


func _on_z_spinbox_changed(new_value: float):
	waypoint_node.transform.origin.z = new_value


# PUBLIC


func assign_waypoint(waypoint):
	waypoint_node = waypoint
	waypoint_node.connect("renamed", self, "_on_waypoint_renamed")
	waypoint_node.connect("tree_exiting", self, "_on_waypoint_tree_exiting")

	name_label.set_text(waypoint.name)

	pos_x_spinbox.set_value(waypoint.transform.origin.x)
	pos_y_spinbox.set_value(waypoint.transform.origin.y)
	pos_z_spinbox.set_value(waypoint.transform.origin.z)


signal delete_pressed
signal name_changed
