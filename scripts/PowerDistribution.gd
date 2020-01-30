extends HBoxContainer

onready var weapon_bar = get_node("Weapon Container/TextureProgress")
onready var shield_bar = get_node("Shield Container/TextureProgress")
onready var engine_bar = get_node("Engine Container/TextureProgress")


func set_power_bars(power_dist: Array):
	weapon_bar.set_value(power_dist[ShipBase.WEAPON])
	shield_bar.set_value(power_dist[ShipBase.SHIELD])
	engine_bar.set_value(power_dist[ShipBase.ENGINE])


const ShipBase = preload("ShipBase.gd")
