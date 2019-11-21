extends Control

onready var button = get_node("TextureButton")
onready var label = get_node("Label")

var camera: Camera
var node = null
var position_offset: Vector2


func _ready():
	camera = get_viewport().get_camera()
	button.connect("pressed", self, "_on_button_pressed")
	position_offset = button.rect_size / 2


func _on_button_pressed():
	emit_signal("pressed", node)


func _process(delta):
	if camera.is_position_behind(node.transform.origin):
		if visible:
			hide()
	else:
		if not visible:
			show()

		var pos = camera.unproject_position(node.transform.origin)
		set_position(pos - position_offset)


# PUBLIC


func set_color(new_color: Color):
	button.set_modulate(new_color)


func set_node(new_node):
	node = new_node
	node.connect("exit_tree", self, "queue_free")


signal pressed
