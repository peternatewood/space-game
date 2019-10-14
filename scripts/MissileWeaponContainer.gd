extends HBoxContainer

onready var ammo_label = get_node("Missile Ammo")
onready var arrow = get_node("Arrow/Polygon2D")
onready var capacity_label = get_node("Missile Capacity")
onready var name_label = get_node("Missile Name")


func set_ammo(ammo: int):
	ammo_label.set_text(str(ammo))


func set_capacity(capacity: int):
	capacity_label.set_text(str(capacity))
	set_ammo(capacity)
	capacity_label.set_custom_minimum_size(capacity_label.rect_size)


func set_name(name: String):
	name_label.set_text(name)


func toggle_arrow(show_arrow: bool):
	if show_arrow:
		arrow.show()
	else:
		arrow.hide()
