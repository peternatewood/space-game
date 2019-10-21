extends Control

enum TYPE { SHIP, ENERGY_WEAPON, MISSILE_WEAPON }

export (TYPE) var slot_type

onready var area = get_node("Area")
onready var highlight = get_node("Area/Highlight")
onready var sprite = get_node("Area/Sprite")


func _ready():
	area.connect("area_entered", self, "_on_area_entered")
	area.connect("area_exited", self, "_on_area_exited")


func _on_area_entered(area):
	if area.has_meta("type") and area.get_meta("type") == slot_type:
		highlight.show()


func _on_area_exited(area):
	if area.has_meta("type") and area.get_meta("type") == slot_type:
		highlight.hide()
