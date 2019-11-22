extends Control

onready var colorable_node_paths: Array = [
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
onready var self_colorable_node_paths: Array = [
	"Target View Container/Target View Rows/Target View Panel Container/Target View Panel"
]
onready var settings = get_node("/root/GlobalSettings")


func _ready():
	set_palette(settings.get_hud_palette())


func set_palette(palette: Dictionary):
	for path in colorable_node_paths:
		var node = get_node_or_null(path)

		if node == null:
			print("Invalid node path! " + path)
		else:
			var color: Color = palette.get(path, palette.default)
			node.set_modulate(color)
