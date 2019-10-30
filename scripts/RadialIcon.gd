extends TextureButton


func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	set_modulate(HOVER_COLOR)


func _on_mouse_entered():
	set_modulate(Color.white)


func _on_mouse_exited():
	set_modulate(HOVER_COLOR)


const HOVER_COLOR: Color = Color(1, 1, 1, 0.5)
