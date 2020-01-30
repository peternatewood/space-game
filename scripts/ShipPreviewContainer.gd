extends Control

export (bool) var show_description = false

onready var camera = get_node("Viewport/Camera")
onready var description = get_node("Description")
onready var beam_turrets_label = get_node("Columns/Details/Beam Weapon Turrets")
onready var energy_turrets_label = get_node("Columns/Details/Energy Weapon Turrets")
onready var energy_weapons_label = get_node("Columns/Details/Energy Weapon Slots")
onready var hull_label = get_node("Columns/Details/Hull Strength")
onready var missile_turrets_label = get_node("Columns/Details/Missile Weapon Turrets")
onready var missile_weapons_label = get_node("Columns/Details/Missile Weapon Slots")
onready var preview = get_node("Viewport")
onready var preview_ship = get_node("Viewport/Preview Ship")
onready var shield_label = get_node("Columns/Details/Shield Strength")
onready var ship_class_label = get_node("Ship Class")
onready var speed_label = get_node("Columns/Details/Ship Speed")
onready var weapon_capacity_label = get_node("Columns/Details/Weapon Capacity")

var capital_ship_labels: Array = []
var small_ship_labels: Array = []


func _ready():
	var tree = get_tree()
	small_ship_labels = tree.get_nodes_in_group("small_ship_labels")
	capital_ship_labels = tree.get_nodes_in_group("capital_ship_labels")

	set_cam_position()
	toggle_ship_exhaust(false)

	if show_description:
		description.show()


func _process(delta):
	if visible:
		preview_ship.rotate_y(delta * RADIANS_PER_SECOND)


# PUBLIC


func set_cam_position():
	camera.transform.origin = 1.5 * preview_ship.cam_distance * Vector3.BACK + (preview_ship.cam_distance / 4) * Vector3.UP
	camera.look_at(preview_ship.transform.origin, Vector3.UP)


func set_ship(ship_class: String, ship_data: Dictionary, ship_instance):
	if show_description:
		description.set_text(ship_data.description)

	hull_label.set_text(ShipBase.get_hitpoints_strength(ship_data.hull_hitpoints))
	ship_class_label.set_text(ship_class)
	speed_label.set_text(str(10 * ship_data.max_speed) + " m/s")

	if ship_data.is_capital_ship:
		for label in small_ship_labels:
			label.hide()

		for label in capital_ship_labels:
			label.show()

		beam_turrets_label.set_text(str(ship_data.beam_weapon_turrets))
		energy_turrets_label.set_text(str(ship_data.energy_weapon_turrets))
		missile_turrets_label.set_text(str(ship_data.missile_weapon_turrets))
	else:
		for label in small_ship_labels:
			label.show()

		for label in capital_ship_labels:
			label.hide()

		energy_weapons_label.set_text(str(ship_data.energy_weapon_slots))
		missile_weapons_label.set_text(str(ship_data.missile_weapon_slots))
		shield_label.set_text(ShipBase.get_hitpoints_strength(ship_data.shield_hitpoints))
		weapon_capacity_label.set_text(ShipBase.get_weapon_capacity_level(ship_data.missile_capacity))

	var ship_rotation: Vector3 = preview_ship.rotation
	preview_ship.free()

	ship_instance.set_script(ShipBase)
	preview.add_child(ship_instance)
	preview_ship = ship_instance
	preview_ship.set_rotation(ship_rotation)

	set_cam_position()
	toggle_ship_exhaust(false)


func toggle_ship_exhaust(toggle_on: bool):
	var exhaust_points = preview_ship.get_node_or_null("Exhaust Points")

	if toggle_on:
		preview_ship.exhaust.show()
		if exhaust_points != null:
			exhaust_points.show()
	else:
		preview_ship.exhaust.hide()
		if exhaust_points != null:
			exhaust_points.hide()


const ShipBase = preload("ShipBase.gd")

const RADIANS_PER_SECOND: float = PI / -2
