extends Control

onready var add_target_button = get_node("Add Target Button")
onready var target_rows = get_node("Targets Rows")
onready var type_options = get_node("Requirement Grid/Type Options")
onready var waypoint_options = get_node("Requirement Grid/Waypoints Options")

var ship_names: Array = []


func _ready():
	add_target_button.connect("pressed", self, "_on_add_target_pressed")


func _on_add_target_pressed():
	add_target()


# PUBLIC


func add_target(name: String = ""):
	var target = REQUIREMENT_TARGET.instance()
	target_rows.add_child(target)
	target.populate_options(ship_names)
	target.select_name(name)


func populate_fields(data):
	type_options.select(data.type)
	var target_index: int = 0
	var target_count = target_rows.get_child_count()
	for name in data.target_names:
		if target_index < target_count:
			var target = target_rows.get_child(target_index)
			target.select_name(name)
		else:
			add_target(name)

		target_index += 1


func update_ships(ship_names: Array):
	ship_names = ship_names
	for target in target_rows.get_children():
		target.populate_options(ship_names)


const REQUIREMENT_TARGET = preload("res://editor/prefabs/requirement_target.tscn")
