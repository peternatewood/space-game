extends Node2D

var has_target: bool = false
var target


func _on_target_destroyed():
	queue_free()


# PUBLIC


func set_target(node):
	has_target = true
	target = node
	target.connect("destroyed", self, "_on_target_destroyed")
