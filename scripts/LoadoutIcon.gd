extends Control

onready var icon = get_node("Icon")
onready var label = get_node("Label")

var ship_class: String
var weapon_name: String


func _ready():
	set_modulate(NORMAL_COLOR)

	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("pressed", self, "_on_mouse_exited")


func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		emit_signal("pressed")


func _on_mouse_entered():
	set_modulate(Color.white)


func _on_mouse_exited():
	set_modulate(NORMAL_COLOR)


# PUBLIC


func set_ship(new_ship_class: String, image: ImageTexture):
	ship_class = new_ship_class
	label.set_text(ship_class)
	icon.set_texture(image)


func set_weapon(new_weapon_name: String, image: ImageTexture):
	weapon_name = new_weapon_name
	label.set_text(weapon_name)
	icon.set_texture(image)


signal pressed

const NORMAL_COLOR: Color = Color(1, 1, 1, 0.5)
