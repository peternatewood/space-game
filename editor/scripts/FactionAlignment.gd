extends Control

onready var alignment_options = get_node("Alignment Options")
onready var faction_name = get_node("Faction Name")


func _ready():
	alignment_options.connect("item_selected", self, "_on_alignment_selected")


func _on_alignment_selected(item_index: int):
	emit_signal("alignment_changed", item_index)


signal alignment_changed
