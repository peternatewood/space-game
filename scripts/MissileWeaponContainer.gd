extends HBoxContainer

onready var ammo_label = get_node("Missile Ammo")
onready var name_label = get_node("Missile Name")


func set_ammo(ammo: int):
	ammo_label.set_text(str(ammo))


func set_name(name: String):
	name_label.set_text(name)
