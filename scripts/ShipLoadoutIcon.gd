extends Control

onready var draggable_icon = get_node("Draggable Icon")
onready var icon_texture = get_node("TextureRect")
onready var ship_name = get_node("Ship Name")

var being_dragged: bool = false
var is_mouse_down: bool = false
var mouse_pos: Vector2
var ship_class


func _ready():
	self.connect("mouse_entered", self, "_on_mouse_entered")
	self.connect("mouse_exited", self, "_on_mouse_exited")


func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			is_mouse_down = true
			mouse_pos = event.position
			emit_signal("icon_clicked", self)
		elif is_mouse_down:
			is_mouse_down = false

			if being_dragged:
				emit_signal("draggable_icon_dropped", self)
				being_dragged = false
				draggable_icon.hide()
	elif event is InputEventMouseMotion:
		if not being_dragged and is_mouse_down:
			being_dragged = true
			draggable_icon.show()
		if being_dragged:
			mouse_pos += event.relative


func _on_mouse_entered():
	ship_name.show()


func _on_mouse_exited():
	ship_name.hide()


func _process(delta):
	if being_dragged:
		draggable_icon.set_position(mouse_pos)


# PUBLIC


func set_ship(name, image_resource):
	ship_name.set_text(name)
	ship_class = name
	icon_texture.set_texture(image_resource)

	var ship_sprite = draggable_icon.get_node("Ship Sprite")
	ship_sprite.set_texture(image_resource)


signal icon_clicked
signal draggable_icon_dropped
