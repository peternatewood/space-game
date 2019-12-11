extends Control

onready var delete_button = get_node("Delete Button")
onready var name_lineedit = get_node("Name LineEdit")
onready var rows = get_node("Rows")

var alignments: Dictionary = {}
var faction_name: String
var user_entering: bool = true


func _ready():
	delete_button.connect("pressed", self, "_on_delete_pressed")
	name_lineedit.connect("text_changed", self, "_on_text_changed")


func _on_delete_pressed():
	emit_signal("deleted", faction_name)
	queue_free()


func _on_text_changed(new_text: String):
	if user_entering and new_text != "":
		emit_signal("faction_name_changed", faction_name, new_text)
		faction_name = new_text


# PUBLIC


func add_faction_alignment(new_faction_name: String):
	if new_faction_name == name_lineedit.text:
		print("Don't add alignments to same faction name")
	else:
		alignments[new_faction_name] = 0

		var faction_alignment_instance = FACTION_ALIGNMENT.instance()
		rows.add_child(faction_alignment_instance)
		faction_alignment_instance.alignment_options.select(alignments[new_faction_name])
		faction_alignment_instance.faction_lineedit.set_text(new_faction_name)


func remove_faction(removed_faction: String):
	for faction_alignment in rows.get_children():
		if faction_alignment.faction_lineedit.text == removed_faction:
			faction_alignment.queue_free()
			break

	alignments.erase(removed_faction)


func set_faction_alignments(faction_data: Dictionary):
	user_entering = false
	alignments = faction_data

	var old_faction_count: int = rows.get_child_count()
	var new_faction_count: int = faction_data.size()

	var faction_alignments = rows.get_children()
	var faction_names = faction_data.keys()

	for index in range(max(old_faction_count, new_faction_count)):
		if index >= old_faction_count:
			# Add new faction
			var faction: String = faction_names[index]
			var alignment = FACTION_ALIGNMENT.instance()

			rows.add_child(alignment)
			alignment.alignment_options.select(faction_data[faction])
			alignment.faction_lineedit.set_text(faction)
		elif index >= new_faction_count:
			# Remove old faction
			faction_alignments[index].queue_free
		else:
			# Update faction
			var faction: String = faction_names[index]
			var alignment = rows.get_child(index)

			alignment.alignment_options.select(faction_data[faction])
			alignment.faction_lineedit.set_text(faction)

	user_entering = true


func set_faction_name(new_name: String):
	user_entering = false

	faction_name = new_name
	name_lineedit.set_text(new_name)

	user_entering = true


func update_faction_names(old_name: String, new_name: String):
	if old_name != faction_name:
		var new_alignment: int = 0

		for alignment_name in alignments.keys():
			if alignment_name == old_name:
				new_alignment = alignments[alignment_name]

		alignments[new_name] = new_alignment
		alignments.erase(old_name)

		user_entering = false

		for faction_alignment in rows.get_children():
			if faction_alignment.faction_lineedit.text == old_name:
				faction_alignment.faction_lineedit.set_text(new_name)
				break

		user_entering = true


signal deleted
signal faction_name_changed

const FACTION_ALIGNMENT = preload("res://editor/prefabs/faction_alignment.tscn")
