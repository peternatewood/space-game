extends Control


func _ready():
	var close_button = get_node("Rows/Column/Close Button")
	close_button.connect("pressed", self, "hide")

	var tree = get_node("Rows/Tree")
	var tree_root = tree.create_item()
	tree.set_hide_root(true)

	for section in MANUAL_TEXT.keys():
		var section_item = tree.create_item(tree_root)
		section_item.set_text(0, section)
		section_item.set_collapsed(true)
		section_item.set_expand_right(0, false)

		for text in MANUAL_TEXT[section]:
			var child = tree.create_item(section_item)
			child.set_expand_right(0, false)

			if text is String:
				child.set_text(0, text)
			elif text is Dictionary:
				child.set_text(0, text.title)
				child.set_collapsed(true)

				for child_text in text.rows:
					var child_details = tree.create_item(child)
					child_details.set_text(0, child_text)
					child_details.set_expand_right(0, false)


const MANUAL_TEXT: Dictionary = {
	"Mission Nodes": [
		"Add a Mission to the list with the Add Mission button below the description field.",
		"The first Mission node in the list will be the starting mission in the campaign.",
		"Use the Up and Down buttons to reorder the Mission nodes.",
	],
	"Linking Missions": [
		"Each Mission node can link to one or more other missions.",
		"Click the Add Mission + button on a Mission node to add a Next Mission node.",
		"If you choose a mission that isn't already in the mission list, a Mission node will be added automatically.",
		{
			"title": "Add Objective Requirements nodes to determine which mission the player will play next.",
			"rows": [
				"When a player completes all critical objectives in a mission, the game looks through the list of Next Missions in order, and chooses the first mission whose requirements are met.",
				"Use the < and > buttons to reorder Next Mission nodes.",
				"If a Next Mission node has no Objective Requirement nodes, its requirements will be considered met by default.",
				"If the node has multiple Objective Requirement nodes, they must all be completed to load that mission next.",
				"If a mission leads to multiple possible missions based on different objectives being completed, list the Next Mission nodes in order of decreasingly strict requirements.",
				"NOTE: There must be at least one Next Mission node that has no requirements except for the last Mission node in the list"
			]
		}
	]
}
