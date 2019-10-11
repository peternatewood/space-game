tool
extends "res://scripts/PostImportActor.gd"


func post_import(scene):
	# This is used for loading the data file and other resources
	var source_folder = get_source_folder()
	var data_file = File.new()
	var data_file_name: String = source_folder + "/data.json"

	# Set defaults to be overridden by data file
	var missile_data: Dictionary = {
		"acceleration": 1.0,
		"ammo_cost": 2.0,
		"damage_hull": 10.0,
		"damage_shield": 5.0,
	  "fire_delay": 1.5,
	  "life": 10.0,
		"max_speed": 100.0,
		"search_radius": 10.0,
		"turn_speed": 1.0,
		"weapon_name": "missile"
	}

	if data_file.file_exists(data_file_name):
		data_file.open(data_file_name, File.READ)

		var data_parsed = JSON.parse(data_file.get_as_text())
		if data_parsed.error == OK:
			var acceleration = data_parsed.result.get("acceleration")
			if acceleration != null and typeof(acceleration) == TYPE_REAL:
				missile_data["acceleration"] = acceleration

			var ammo_cost = data_parsed.result.get("ammo_cost")
			if ammo_cost != null and typeof(ammo_cost) == TYPE_REAL:
				missile_data["ammo_cost"] = ammo_cost

			var damage_hull = data_parsed.result.get("damage_hull")
			if damage_hull != null and typeof(damage_hull) == TYPE_REAL:
				missile_data["damage_hull"] = damage_hull

			var damage_shield = data_parsed.result.get("damage_shield")
			if damage_shield != null and typeof(damage_shield) == TYPE_REAL:
				missile_data["damage_shield"] = damage_shield

			var fire_delay = data_parsed.result.get("fire_delay")
			if fire_delay != null and typeof(fire_delay) == TYPE_REAL:
				missile_data["fire_delay"] = fire_delay

			var life = data_parsed.result.get("life")
			if life != null and typeof(life) == TYPE_REAL:
				missile_data["life"] = life

			var max_speed = data_parsed.result.get("max_speed")
			if max_speed != null and typeof(max_speed) == TYPE_REAL:
				missile_data["max_speed"] = max_speed

			var search_radius = data_parsed.result.get("search_radius")
			if search_radius != null and typeof(search_radius) == TYPE_REAL:
				missile_data["search_radius"] = search_radius

			var turn_speed = data_parsed.result.get("turn_speed")
			if turn_speed != null and typeof(turn_speed) == TYPE_REAL:
				missile_data["turn_speed"] = turn_speed

			var weapon_name = data_parsed.result.get("name")
			if weapon_name != null and typeof(weapon_name) == TYPE_STRING:
				missile_data["weapon_name"] = weapon_name
		else:
			print("Error while parsing data file: ", data_file_name + " " + data_parsed.error_string)
	else:
		print("No such file: " + data_file_name)

	scene.set_meta("acceleration", missile_data["acceleration"])
	scene.set_meta("ammo_cost", missile_data["ammo_cost"])
	scene.set_meta("damage_hull", missile_data["damage_hull"])
	scene.set_meta("damage_shield", missile_data["damage_shield"])
	scene.set_meta("fire_delay", missile_data["fire_delay"])
	scene.set_meta("life", missile_data["life"])
	scene.set_meta("max_speed", missile_data["max_speed"])
	scene.set_meta("search_radius", missile_data["search_radius"])
	scene.set_meta("turn_speed", missile_data["turn_speed"])
	scene.set_meta("weapon_name", missile_data["weapon_name"])

	# Avg speed when accelerating: (max_speed - acceleration) / 2 | Seconds to reach max speed: max_speed / acceleration | Add max speed multiplied by remaining seconds
	# Avg accel speed: (100 - 20) / 2 = 40 | Seconds to max speed: 100 / 20 = 5
	# 40 * 5 + 100 * (12 - 5)
	var seconds_to_max: float = missile_data["max_speed"] / missile_data["acceleration"]
	var firing_range: float = ((missile_data["max_speed"] - missile_data["acceleration"]) / 2) * seconds_to_max + missile_data["max_speed"] * (missile_data["life"] - seconds_to_max)
	scene.set_meta("firing_range", firing_range)

	scene.set_mass(0.2)
	scene.set_script(Missile)

	return .post_import(scene)


const Missile = preload("Missile.gd")
