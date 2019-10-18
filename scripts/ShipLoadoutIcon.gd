extends Control

onready var default_modulate = get_modulate()
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

				var over_area
				var overlapping_areas = draggable_icon.get_overlapping_areas()
				if overlapping_areas.size() == 1:
					over_area = overlapping_areas[0]
				elif overlapping_areas.size() > 1:
					# Get one closest to mouse
					var closest_dist: float = -1
					var closest_index: float = -1
					for index in range(overlapping_areas.size()):
						var dist_squared = (overlapping_areas[index].position - mouse_pos).length_squared()
						if dist_squared < closest_dist or closest_index == -1:
							closest_dist = dist_squared
							closest_index = index

					over_area = overlapping_areas[closest_index]

				emit_signal("draggable_icon_dropped", self, over_area)
				being_dragged = false
				_toggle_draggable_icon(false)
	elif event is InputEventMouseMotion:
		if not being_dragged and is_mouse_down:
			being_dragged = true
			_toggle_draggable_icon(true)
		if being_dragged:
			mouse_pos += event.relative


func _on_mouse_entered():
	set_modulate(Color.white)
	ship_name.show()


func _on_mouse_exited():
	set_modulate(default_modulate)
	ship_name.hide()


func _process(delta):
	if being_dragged:
		draggable_icon.set_position(mouse_pos)


func _toggle_draggable_icon(enable: bool):
	if enable:
		draggable_icon.show()
	else:
		draggable_icon.hide()

	draggable_icon.set_monitorable(enable)
	draggable_icon.set_monitoring(enable)


# PUBLIC


func get_texture():
	return icon_texture.get_texture()


func set_ship(name, image_resource):
	ship_name.set_text(name)
	ship_class = name
	icon_texture.set_texture(image_resource)

	var ship_sprite = draggable_icon.get_node("Ship Sprite")
	ship_sprite.set_texture(image_resource)


signal icon_clicked
signal draggable_icon_dropped
