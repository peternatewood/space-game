extends Control

onready var edge_target_icon = get_node("Edge Target Icon")
onready var lead_indicator = get_node("Lead Indicator")
onready var target_class = get_node("Target View Container/Target View Rows/Target Class")
onready var target_details_minimal = get_node("Target Details Minimal")
onready var target_icon = get_node("Target Icon")
onready var target_name = get_node("Target View Container/Target View Rows/Target Name")

var current_node_path: String
var is_current_node_self_modulated: bool = false


func _ready():
	set_palette(GlobalSettings.get_hud_palette())

	# Listen for colorable nodes getting clicked on
	for path in COLORABLE_NODE_PATHS:
		var node = get_node_or_null(path)

		if node == null:
			print("Invalid node path! " + path)
		else:
			node.connect("gui_input", self, "_on_colorable_node_gui_input", [ node, path ])
			set_icon_color(path)

	for path in SELF_COLORABLE_NODE_PATHS:
		var node = get_node_or_null(path)

		if node == null:
			print("Invalid node path! " + path)
		else:
			node.connect("gui_input", self, "_on_colorable_node_gui_input", [ node, path, true ])
			set_icon_color(path)

	# Show normally hidden nodes
	lead_indicator.show()
	get_node("Target Overhead").show()
	get_node("Target Details Minimal").show()
	get_node("Target View Container").show()

	var communications_menu = get_node("Communications Menu")
	communications_menu.show()
	communications_menu.set_script(null)

	edge_target_icon.show()
	target_icon.show()

	# Hide a few nodes that are covering other nodes we need to click on
	get_node("Radar/Radar Icons Container").hide()

	GlobalSettings.connect("hud_palette_color_changed", self, "set_icon_color")
	GlobalSettings.connect("ui_colors_changed", self, "update_colored_icons")
	update_colored_icons()


func _on_colorable_node_gui_input(event, node, path: String, is_self_modulated: bool = false):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		current_node_path = path
		is_current_node_self_modulated = is_self_modulated

		emit_signal("colorable_node_clicked", node)


# PUBLIC


func set_current_icon_color(new_color: Color, update_GlobalSettings: bool = true):
	if update_GlobalSettings:
		GlobalSettings.set_hud_custom_color(current_node_path, new_color)
	else:
		var node = get_node_or_null(current_node_path)
		if node == null:
			print("Invalid node path! " + current_node_path)
		else:
			if SELF_COLORABLE_NODE_PATHS.has(current_node_path):
				node.set_self_modulate(new_color)
			else:
				node.set_modulate(new_color)


func set_icon_color(path: String):
	var node = get_node_or_null(path)
	var is_self_modulated = SELF_COLORABLE_NODE_PATHS.has(path)

	if node == null:
		print("Invalid node path! " + path)
	else:
		var color = GlobalSettings.get_hud_custom_color(path)

		if is_self_modulated:
			node.set_self_modulate(color)
		else:
			node.set_modulate(color)


func set_palette(palette: Dictionary):
	for path in COLORABLE_NODE_PATHS:
		var node = get_node_or_null(path)

		if node == null:
			print("Invalid node path! " + path)
		else:
			var color: Color = palette.get(path, palette.default)
			node.set_modulate(color)

	for path in SELF_COLORABLE_NODE_PATHS:
		var node = get_node_or_null(path)

		if node == null:
			print("Invalid node path! " + path)
		else:
			var color: Color = palette.get(path, palette.default)
			node.set_self_modulate(color)


func update_colored_icons():
	var target_color = GlobalSettings.get_interface_color(2)

	edge_target_icon.set_modulate(target_color)
	lead_indicator.set_modulate(target_color)
	target_details_minimal.set_modulate(target_color)
	target_class.set_modulate(target_color)
	target_icon.set_modulate(target_color)
	target_name.set_modulate(target_color)


signal colorable_node_clicked

const COLORABLE_NODE_PATHS: Array = [
	"HUD Bars",
	"Mission Timer",
	"Damage Bars Panel",
	"Communications Menu",
	"Objectives Container",
	"Player Overhead",
	"Power Container",
	"Target Overhead",
	"Throttle Bar Container",
	"Weapon Battery Bar",
	"Weapons Container",
	"Target Reticule Outer",
	"Target Reticule",
	"Radar/Radar Background",
	"Target View Container/Target View Rows/Target Distance Container",
	"Target View Container/Target View Rows/Target View Panel Container/Target Hull Container"
]
const SELF_COLORABLE_NODE_PATHS: Array = [
	"Target View Container/Target View Rows/Target View Panel Container/Target View Panel"
]
