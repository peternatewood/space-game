extends Control

onready var icon_texture = get_node("TextureRect")
onready var ship_name = get_node("Ship Name")

var model


func _ready():
	self.connect("mouse_entered", self, "_on_mouse_entered")
	self.connect("mouse_exited", self, "_on_mouse_exited")


func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		emit_signal("icon_clicked", self)


func _on_mouse_entered():
	ship_name.show()


func _on_mouse_exited():
	ship_name.hide()


# PUBLIC


func set_ship(name, image_resource, model_resource):
	ship_name.set_text(name)
	icon_texture.set_texture(image_resource)
	model = model_resource


signal icon_clicked
