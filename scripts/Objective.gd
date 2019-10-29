extends Object

enum { PRIMARY, SECONDARY, SECRET }
enum { INCOMPLETE, FAILED, COMPLETED }
enum { PATROL, DESTROY, DEFEND, OBJECTIVE }

var state: int = INCOMPLETE
var name: String
var description: String
var is_critical: bool
var success_requirements: Array = []
var failure_requirements: Array = []


func _init(source_dictionary):
	name = source_dictionary.get("name", "name")
	description = source_dictionary.get("description", "description")
	is_critical = source_dictionary.get("is_critical", false)

	for requirement_data in source_dictionary.get("success_requirements", []):
		var requirement = Requirement.new(requirement_data)
		success_requirements.append(requirement)
		requirement.connect("completed", self, "_on_requirement_completed")
		requirement.connect("failed", self, "_on_requirement_failed")

	for requirement_data in source_dictionary.get("failure_requirements", []):
		var requirement = Requirement.new(requirement_data)
		failure_requirements.append(requirement)


func _on_requirement_completed():
	if state != FAILED:
		for requirement in success_requirements:
			if requirement.state != COMPLETED:
				return

		state = COMPLETED
		emit_signal("completed")


func _on_requirement_failed():
	if state != COMPLETED:
		state = FAILED
		emit_signal("failed")


signal completed
signal failed


class Requirement extends Object:
	var objective_index: int
	var objective_type: int
	var state: int = INCOMPLETE
	var type: int
	var target_names: Array = []
	var targets: Array = []
	var targets_destroyed: int = 0
	var time_limit: float
	var waypoints_name: String


	func _init(source_dictionary):
		type = source_dictionary.get("type", PATROL)

		objective_index = source_dictionary.get("objective_index", -1)
		objective_type = source_dictionary.get("objective_type", -1)
		target_names = source_dictionary.get("targets", [])
		time_limit = source_dictionary.get("time_limit", 0.0)
		waypoints_name = source_dictionary.get("waypoints_name", "")


	func _on_objective_completed():
		print("on objective completed")
		state = COMPLETED
		emit_signal("completed")


	func _on_objective_failed():
		print("on objective failed")
		state = FAILED
		emit_signal("failed")


	func _on_target_destroyed():
		targets_destroyed += 1
		if targets_destroyed >= targets.size():
			match type:
				DESTROY:
					state = COMPLETED
					emit_signal("completed")
				DEFEND:
					state = FAILED
					emit_signal("failed")


	signal completed
	signal failed
