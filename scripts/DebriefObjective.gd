extends Control

onready var completed_icon = get_node("Completed Icon")
onready var failed_icon = get_node("Failed Icon")
onready var incomplete_icon = get_node("Incomplete Icon")
onready var objective_name = get_node("Objective Name")
onready var state_label = get_node("State Label")


func set_props(objective):
	objective_name.set_text(objective.name)

	match objective.state:
		objective.INCOMPLETE:
			state_label.set_text("Incomplete")
		objective.COMPLETED:
			incomplete_icon.hide()
			completed_icon.show()
			state_label.set_text("Completed")
		objective.FAILED:
			incomplete_icon.hide()
			failed_icon.show()
			state_label.set_text("Failed")
