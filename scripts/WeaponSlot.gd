extends Control

enum TYPE { SHIP, ENERGY_WEAPON, MISSILE_WEAPON }

export (TYPE) var slot_type

onready var area = get_node("Area")
onready var highlight_polygon = get_node("Area/Highlight")
onready var sprite = get_node("Area/Sprite")

var index: int


func _ready():
	index = get_position_in_parent()


func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		emit_signal("slot_clicked", self, event.position)


# PUBLIC


func highlight(toggle_on: bool):
	if toggle_on:
		highlight_polygon.show()
	else:
		highlight_polygon.hide()


func is_area_same_type(area):
	return area.has_meta("type") and area.get_meta("type") == slot_type

func set_icon(image_resource):
	sprite.set_texture(image_resource)
	sprite.show()


func toggle_icon(toggle_on: bool):
	if toggle_on:
		sprite.show()
	else:
		sprite.hide()


signal slot_clicked
