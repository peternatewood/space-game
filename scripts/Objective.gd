extends Object

enum { PRIMARY, SECONDARY, SECRET }
enum { INCOMPLETE, FAILED, COMPLETED }
enum { PATROL, DESTROY, DEFEND, OBJECTIVE, SHIPS_ARRIVE, SHIPS_LEAVE }

var description: String
var enabled: bool = true
var failure_requirements: Array = []
var is_critical: bool
var name: String
var state: int = INCOMPLETE
var success_requirements: Array = []
var trigger_requirements: Array = []


func _init(source_dictionary):
	name = source_dictionary.get("name", "name")
	description = source_dictionary.get("description", "description")
	is_critical = source_dictionary.get("is_critical", false)

	for requirement_data in source_dictionary.get("success_requirements", []):
		var requirement = Requirement.new(requirement_data)
		success_requirements.append(requirement)
		requirement.connect("completed", self, "_on_success_requirement_completed")
		requirement.connect("failed", self, "_on_success_requirement_failed")

	for requirement_data in source_dictionary.get("failure_requirements", []):
		var requirement = Requirement.new(requirement_data)
		failure_requirements.append(requirement)
		requirement.connect("completed", self, "_on_failure_requirement_completed")
		requirement.connect("failed", self, "_on_failure_requirement_failed")

	for requirement_data in source_dictionary.get("trigger_requirements", []):
		if enabled:
			enabled = false

		var requirement = Requirement.new(requirement_data)
		trigger_requirements.append(requirement)
		requirement.connect("completed", self, "_on_trigger_requirement_completed")


func _on_failure_requirement_completed():
	if not enabled:
		return

	if state != FAILED:
		state = FAILED
		emit_signal("failed")


func _on_failure_requirement_failed():
	# Do we even need to do anything here? Maybe succeed?
	pass


func _on_success_requirement_completed():
	if not enabled:
		return

	if state != FAILED:
		for requirement in success_requirements:
			if requirement.state != COMPLETED:
				return

		state = COMPLETED
		emit_signal("completed")


func _on_success_requirement_failed():
	if not enabled:
		return

	if state != COMPLETED:
		state = FAILED
		emit_signal("failed")


func _on_trigger_requirement_completed():
	if not enabled:
		for requirement in trigger_requirements:
			if requirement.state != COMPLETED:
				return

		enabled = true
		emit_signal("triggered")


# PUBLIC


func connect_targets_to_requirements(targets_container):
	# Connect success requirements
	for requirement in success_requirements:
		for target_name in requirement.target_names:
			var target_node = targets_container.get_node_or_null(target_name)
			if target_node != null:
				requirement.targets.append(target_node)
				target_node.connect("destroyed", requirement, "_on_target_destroyed")
				target_node.connect("warping_in", requirement, "_on_target_warping_in")
				target_node.connect("warped_out", requirement, "_on_target_warped_out")

	# Also connect all failure requirements
	for requirement in failure_requirements:
		for target_name in requirement.target_names:
			var target_node = targets_container.get_node_or_null(target_name)
			if target_node != null:
				requirement.targets.append(target_node)
				target_node.connect("destroyed", requirement, "_on_target_destroyed")
				target_node.connect("warping_in", requirement, "_on_target_warping_in")
				target_node.connect("warped_out", requirement, "_on_target_warped_out")

	# And finally, trigger requirements
	for requirement in trigger_requirements:
		for target_name in requirement.target_names:
			var target_node = targets_container.get_node_or_null(target_name)
			if target_node != null:
				requirement.targets.append(target_node)
				target_node.connect("destroyed", requirement, "_on_target_destroyed")
				target_node.connect("warping_in", requirement, "_on_target_warping_in")
				target_node.connect("warped_out", requirement, "_on_target_warped_out")


signal completed
signal failed
signal triggered


class Requirement extends Object:
	var objective_index: int
	var objective_type: int
	var state: int = INCOMPLETE
	var type: int
	var target_names: Array = []
	var targets: Array = []
	var target_counter: int = 0
	var time_limit: float
	var warp_in_counter: int = 0
	var waypoints_name: String


	func _init(source_dictionary):
		type = source_dictionary.get("type", PATROL)

		objective_index = source_dictionary.get("objective_index", -1)
		objective_type = source_dictionary.get("objective_type", -1)
		target_names = source_dictionary.get("targets", [])
		time_limit = source_dictionary.get("time_limit", 0.0)
		waypoints_name = source_dictionary.get("waypoints_name", "")


	func _on_objective_completed():
		state = COMPLETED
		emit_signal("completed")


	func _on_objective_failed():
		state = FAILED
		emit_signal("failed")


	func _on_target_destroyed():
		target_counter += 1
		if target_counter >= targets.size():
			match type:
				DESTROY:
					state = COMPLETED
					emit_signal("completed")
				DEFEND:
					state = FAILED
					emit_signal("failed")


	func _on_target_warping_in():
		if type == SHIPS_ARRIVE:
			warp_in_counter += 1
			if warp_in_counter >= targets.size():
				state = COMPLETED
				emit_signal("completed")


	func _on_target_warped_out():
		if type == SHIPS_LEAVE:
			target_counter += 1
			if target_counter >= targets.size():
				state = COMPLETED
				emit_signal("completed")


	signal completed
	signal failed
