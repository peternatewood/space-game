extends Control


func _on_icon_clicked(node):
	emit_signal("icon_clicked", node)


# PUBLIC


func add_icon(node):
	var icon_instance = ICON.instance()
	add_child(icon_instance)
	icon_instance.set_node(node)
	icon_instance.connect("pressed", self, "_on_icon_clicked")


signal icon_clicked

const ICON = preload("res://editor/prefabs/actor_icon.tscn")
