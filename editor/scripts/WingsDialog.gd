extends AcceptDialog

var reinforcement_checkboxes: Array = []
var wing_lineedits: Array = []


func _ready():
	var grid = get_node("Wings Dialog Rows/Wings ScrollContainer/Wing Grid")

	for child in grid.get_children():
		if child is LineEdit:
			wing_lineedits.append(child)
		elif child is CheckBox:
			reinforcement_checkboxes.append(child)


# PUBLIC


func get_reinforcement_wings():
	var wings: Array = []

	var index: int = 0
	for checkbox in reinforcement_checkboxes:
		if checkbox.pressed:
			wings.append(wing_lineedits[index].text)

		index += 1

	return wings


func get_wing_names():
	var name_list: Array = []

	for lineedit in wing_lineedits:
		name_list.append(lineedit.text)

	return name_list


func populate_wing_names(wing_names: Array = []):
	for index in range(min(wing_names.size(), wing_lineedits.size())):
		wing_lineedits[index].set_text(wing_names[index])
