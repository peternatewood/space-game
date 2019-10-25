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
			for key in missile_data.keys():
				var property = data_parsed.result.get(key)
				if property != null and typeof(property) == typeof(missile_data[key]):
					missile_data[key] = property

			var weapon_name = data_parsed.result.get("name")
			if weapon_name != null and typeof(weapon_name) == TYPE_STRING:
				missile_data["weapon_name"] = weapon_name
		else:
			print("Error while parsing data file: ", data_file_name + " " + data_parsed.error_string)
	else:
		print("No such file: " + data_file_name)

	for key in missile_data.keys():
		scene.set_meta(key, missile_data[key])

	scene.set_meta("source_folder", get_source_folder())

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
