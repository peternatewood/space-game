extends AcceptDialog

onready var name_lineedit = get_node("Details Rows/Details Name Container/Name LineEdit")
onready var briefing_textedit = get_node("Details Rows/Briefing TextEdit")


func populate_fields(mission_name: String, briefing: Array):
	name_lineedit.set_text(mission_name)
	briefing_textedit.set_text(briefing[0])
