extends Control

onready var cost = get_node("Weapon Details/Cost")
onready var cost_label = get_node("Weapon Details/Cost Label")
onready var fire_rate = get_node("Weapon Details/Fire Rate")
onready var hull_damage = get_node("Weapon Details/Hull Damage")
onready var name_label = get_node("Weapon Details/Name")
onready var shield_damage = get_node("Weapon Details/Shield Damage")
onready var video_player = get_node("Video Player")
onready var weight = get_node("Weapon Details/Weight")
onready var weight_label = get_node("Weapon Details/Weight Label")


func _ready():
	video_player.connect("finished", video_player, "play")


# PUBLIC


func set_weapon(type: String, weapon_name: String, weapon_data):
	if not visible:
		show()

	fire_rate.set_text(str(1 / weapon_data.fire_delay) + " rps")
	hull_damage.set_text(weapon_data.hull_damage)
	name_label.set_text(weapon_name)
	shield_damage.set_text(weapon_data.shield_damage)

	match type:
		"energy_weapon":
			cost.set_text(str(weapon_data.cost))
			cost.show()
			cost_label.show()
			weight.hide()
			weight_label.hide()
		"missile_weapon":
			cost.hide()
			cost_label.hide()
			weight.set_text(str(weapon_data.weight))
			weight.show()
			weight_label.show()

	video_player.set_stream(weapon_data.video)

	video_player.play()
