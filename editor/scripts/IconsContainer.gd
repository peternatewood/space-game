extends Control


func _on_icon_clicked(node):
	emit_signal("icon_clicked", node)


func _on_waypoint_icon_clicked(node):
	emit_signal("waypoint_icon_clicked", node)


# PUBLIC


func add_icon(node):
	var icon_instance = ICON.instance()
	add_child(icon_instance)
	icon_instance.set_node(node)
	icon_instance.connect("pressed", self, "_on_icon_clicked")


func add_waypoint_icon(node):
	var icon_instance = WAYPOINT_ICON.instance()
	add_child(icon_instance)
	icon_instance.set_node(node)
	icon_instance.connect("pressed", self, "_on_waypoint_icon_clicked")


signal icon_clicked
signal waypoint_icon_clicked

const ICON = preload("res://editor/prefabs/actor_icon.tscn")
const WAYPOINT_ICON = preload("res://editor/prefabs/waypoint_icon.tscn")
