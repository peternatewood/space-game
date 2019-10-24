extends Object

enum { PRIMARY, SECONDARY, SECRET }
enum { INCOMPLETE, FAILED, ACCOMPLISHED }
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

	for requirement in source_dictionary.get("success_requirements", []):
		success_requirements.append(Requirement.new(requirement))

	for requirement in source_dictionary.get("failure_requirements", []):
		failure_requirements.append(Requirement.new(requirement))


class Requirement:
	var objective
	var type: int
	var target_names: Array = []
	var targets: Array = []
	var time_limit: float
	var waypoints_name: String


	func _init(source_dictionary):
		type = source_dictionary.get("type", PATROL)
		target_names = source_dictionary.get("targets", [])
		time_limit = source_dictionary.get("time_limit", 0.0)
		waypoints_name = source_dictionary.get("waypoints_name", "")
