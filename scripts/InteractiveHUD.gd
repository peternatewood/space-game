extends Control

onready var edge_target_icon = get_node("Edge Target Icon")
onready var settings = get_node("/root/GlobalSettings")
onready var target_class = get_node("Target View Container/Target View Rows/Target Class")
onready var target_icon = get_node("Target Icon")
onready var target_name = get_node("Target View Container/Target View Rows/Target Name")


func _ready():
	set_palette(settings.get_hud_palette())

	# Show normally hidden nodes
	get_node("Communications Menu").show()
	get_node("Target Overhead").show()
	get_node("Target Details Minimal").show()
	get_node("Target View Container").show()

	edge_target_icon.show()
	target_icon.show()

	settings.connect("ui_colors_changed", self, "update_colored_icons")
	update_colored_icons()


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
	var target_color = settings.get_interface_color(2)

	edge_target_icon.set_modulate(target_color)
	target_class.set_modulate(target_color)
	target_icon.set_modulate(target_color)
	target_name.set_modulate(target_color)


const COLORABLE_NODE_PATHS: Array = [
	"HUD Bars",
	"Mission Timer",
	"Hull Bar",
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
	"Target Details Minimal",
	"Radar/TextureRect",
	"Target View Container/Target View Rows/Target Distance Container",
	"Target View Container/Target View Rows/Target View Panel Container/Target Hull Container"
]
const SELF_COLORABLE_NODE_PATHS: Array = [
	"Target View Container/Target View Rows/Target View Panel Container/Target View Panel"
]
