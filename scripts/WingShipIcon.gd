extends Area2D

export (bool) var enabled = true

onready var cross = get_node("Cross")
onready var ship_icon = get_node("Ship Icon")


func _ready():
	if not enabled:
		disable()


# PUBLIC


func disable():
	enabled = false
	cross.show()
	ship_icon.hide()
	set_monitoring(false)
	set_monitorable(false)


func set_icon(image_resource):
	ship_icon.set_texture(image_resource)
