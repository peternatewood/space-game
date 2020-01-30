extends Control

export (bool) var show_description = false

onready var cost = get_node("Columns/Details/Cost")
onready var description = get_node("Description")
onready var duration = get_node("Columns/Details/Duration")
onready var fire_rate = get_node("Columns/Details/Fire Rate")
onready var hull_damage = get_node("Columns/Details/Hull Damage")
onready var name_label = get_node("Name")
onready var shield_damage = get_node("Columns/Details/Shield Damage")
onready var video_player = get_node("Columns/Video Player")
onready var weight = get_node("Columns/Details/Weight")

var beam_weapon_labels: Array = []
var energy_weapon_labels: Array = []
var missile_weapon_labels: Array = []


func _ready():
	var tree = get_tree()
	beam_weapon_labels = tree.get_nodes_in_group("beam_weapon_labels")
	energy_weapon_labels = tree.get_nodes_in_group("energy_weapon_labels")
	missile_weapon_labels = tree.get_nodes_in_group("missile_weapon_labels")

	video_player.connect("finished", video_player, "play")

	if show_description:
		description.show()


# PUBLIC


func set_weapon(weapon_name: String, weapon_data, weapon_video):
	if not visible:
		show()

	fire_rate.set_text(str(MathHelper.round_to_places(1 / weapon_data.fire_delay, 2)).pad_decimals(2) + " rps")
	hull_damage.set_text(WeaponBase.get_damage_strength(weapon_data.damage_hull))
	name_label.set_text(weapon_name)
	shield_damage.set_text(WeaponBase.get_damage_strength(weapon_data.damage_shield))

	if show_description:
		description.set_text(weapon_data.description)

	match weapon_data.type:
		"beam_weapon":
			duration.set_text(str(weapon_data.fire_duration) + "s")

			for label in beam_weapon_labels:
				label.show()

			for label in energy_weapon_labels:
				label.hide()

			for label in missile_weapon_labels:
				label.hide()
		"energy_weapon":
			cost.set_text(WeaponBase.get_battery_cost_description(weapon_data.cost))

			for label in beam_weapon_labels:
				label.hide()

			for label in energy_weapon_labels:
				label.show()

			for label in missile_weapon_labels:
				label.hide()
		"missile_weapon":
			weight.set_text(WeaponBase.get_ammo_cost_description(weapon_data.ammo_cost))

			for label in beam_weapon_labels:
				label.hide()

			for label in energy_weapon_labels:
				label.hide()

			for label in missile_weapon_labels:
				label.show()

	video_player.set_stream(weapon_video)
	video_player.play()


const MathHelper = preload("MathHelper.gd")
const WeaponBase = preload("WeaponBase.gd")
