extends AcceptDialog

var wing_lineedits: Array = []


func _ready():
	var rows = get_node("Wings Dialog Rows/Wings ScrollContainer/Wing Rows")
	wing_lineedits = rows.get_children()


# PUBLIC


func get_wing_names():
	var name_list: Array = []

	for lineedit in wing_lineedits:
		name_list.append(lineedit.text)

	return name_list


func populate_wing_names(wing_names: Array = []):
	for index in range(min(wing_names.size(), wing_lineedits.size())):
		wing_lineedits[index].set_text(wing_names[index])
