extends Label


func _on_objective_completed():
	set_modulate(Color.gray)


func _on_objective_failed():
	set_modulate(Color.red)
