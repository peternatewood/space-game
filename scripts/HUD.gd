extends Control

export (NodePath) var camera_path
export (NodePath) var player_path

onready var camera = get_node(camera_path)
onready var player = get_node(player_path)
onready var target_icon = get_node("Target Icon")


func _process(delta):
	if player.has_target:
		if not target_icon.visible:
			target_icon.show()
		target_icon.set_position(camera.unproject_position(player.current_target.transform.origin))
	elif target_icon.visible:
		target_icon.hide()
