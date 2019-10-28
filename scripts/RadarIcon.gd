extends Node2D

var has_target: bool = false
var target
var target_warped_in: bool = true


func _on_target_destroyed():
	queue_free()


func _on_target_warping_in():
	target_warped_in = true
	show()


# PUBLIC


func set_target(node):
	has_target = true
	target = node

	target.connect("destroyed", self, "_on_target_destroyed")
	target.connect("warped_out", self, "_on_target_destroyed")

	if not target.is_warped_in:
		target_warped_in = false
		target.connect("warping_in", self, "_on_target_warping_in")
		hide()
