extends HBoxContainer

onready var arrow = get_node("Arrow/Polygon2D")
onready var name_label = get_node("Weapon Name")


func set_name(name: String):
	name_label.set_text(name)


func toggle_arrow(show_arrow: bool):
	if show_arrow:
		arrow.show()
	else:
		arrow.hide()
