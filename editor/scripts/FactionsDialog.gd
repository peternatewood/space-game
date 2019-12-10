extends AcceptDialog

onready var add_faction_button = get_node("Rows/Add Faction Button")
onready var faction_rows = get_node("Rows/Faction Scroller/Faction Rows")
onready var faction_name_lineedit = get_node("Rows/New Faction Name")


func _ready():
	add_faction_button.connect("pressed", self, "_on_add_faction_pressed")


func _on_add_faction_pressed():
	if faction_name_lineedit.text != "":
		var default_alignments: Dictionary = {}
		for faction_alignment in faction_rows.get_children():
			default_alignments[faction_alignment.faction_name] = 0
			faction_alignment.add_faction_alignment(faction_name_lineedit.text)

		add_faction_edit(faction_name_lineedit.text, default_alignments)


func _on_faction_name_changed(old_name: String, new_name: String):
	for faction_edit in faction_rows.get_children():
		faction_edit.update_faction_names(old_name, new_name)


# PUBLIC


func add_faction_edit(faction_name: String, alignment_data: Dictionary):
	var faction_edit_instance = FACTION_EDIT.instance()
	faction_rows.add_child(faction_edit_instance)
	faction_edit_instance.set_faction_name(faction_name)
	faction_edit_instance.set_faction_alignments(alignment_data)
	faction_edit_instance.connect("faction_name_changed", self, "_on_faction_name_changed")


func get_faction_data():
	var faction_data: Dictionary = {}

	for faction_edit in faction_rows.get_children():
		faction_data[faction_edit.faction_name] = faction_edit.alignments

	return faction_data


func set_factions(faction_data: Dictionary):
	var faction_edits: Array = faction_rows.get_children()
	var faction_names: Array = faction_data.keys()

	var old_factions_count: int = faction_rows.get_child_count()
	var new_factions_count = faction_names.size()

	for index in range(max(old_factions_count, new_factions_count)):
		if index >= old_factions_count:
			# Add faction edit
			var faction_name: String = faction_names[index]
			add_faction_edit(faction_name, faction_data[faction_name])
		elif index >= new_factions_count:
			# Remove old faction edit
			faction_edits[index].queue_free()
		else:
			# Update exising edit
			var faction_name: String = faction_names[index]
			faction_edits[index].set_faction_name(faction_name)
			faction_edits[index].set_faction_alignments(faction_data[faction_name])


const FACTION_EDIT = preload("res://editor/prefabs/faction_edit.tscn")
