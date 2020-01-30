extends Control

onready var title_label = get_node("Rows/Title Label")
onready var objective_rows =  get_node("Rows/Objective Rows")


func _ready():
	var add_objective_requirement_button = get_node("Rows/Add Objective Requirement Button")
	add_objective_requirement_button.connect("pressed", self, "_on_add_objective_requirement_pressed")


func _on_add_objective_requirement_pressed():
	var objective_requirement = OBJECTIVE_REQUIREMENT_NODE.instance()
	objective_rows.add_child(objective_requirement)


# PUBLIC


func set_mission_title(mission_title: String):
	title_label.set_text(mission_title)


const OBJECTIVE_REQUIREMENT_NODE = preload("res://editor/prefabs/objective_requirement_node.tscn")
