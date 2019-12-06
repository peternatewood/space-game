extends "res://scripts/TurretBase.gd"

onready var hardpoint = get_node("Hardpoint")

var beam


func _ready():
	beam = BLUE_BEAM.instance()
	add_child(beam)
	beam.transform.origin = hardpoint.transform.origin


func _on_target_destroyed():
	beam.has_target = false

	._on_target_destroyed()


func _process(delta):
	if has_target:
		pass


# PUBLIC


func set_target(node = null):
	.set_target(node)

	if has_target:
		beam.set_target(node)


const BLUE_BEAM = preload("res://prefabs/blue_beam.tscn")
