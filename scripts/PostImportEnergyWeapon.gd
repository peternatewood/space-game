tool
extends "res://scripts/PostImportCollision.gd"


func post_import(scene):
	scene.set_script(EnergyBolt)

	# This is used for loading the data file and other resources
	var source_folder = get_source_folder()
	var data_file = File.new()
	var data_file_name: String = source_folder + "/data.json"

	# Set defaults to be overridden by data file
	var energy_data: Dictionary = {
		"cost": 1.0,
		"damage_hull": 10.0,
		"damage_shield": 5.0,
		"damage_subsystem": 2.0,
		"fire_delay": 1.0,
		"life": 4.0,
		"speed": 40.0,
	}
	var weapon_name: String = "energy_weapon"

	if data_file.file_exists(data_file_name):
		data_file.open(data_file_name, File.READ)

		var data_parsed = JSON.parse(data_file.get_as_text())
		if data_parsed.error == OK:
			for key in energy_data.keys():
				var property = data_parsed.result.get(key)
				if property != null and typeof(property) == typeof(energy_data[key]):
					energy_data[key] = property

			var parsed_weapon_name = data_parsed.result.get("name")
			if parsed_weapon_name != null and typeof(parsed_weapon_name) == TYPE_STRING:
				weapon_name = parsed_weapon_name
		else:
			print("Error while parsing data file: ", data_file_name + " " + data_parsed.error_string)

		data_file.close()
	else:
		print("No such file: " + data_file_name)

	for key in energy_data.keys():
		scene.set(key, energy_data[key])

	scene.weapon_name = weapon_name
	# From testing it seems like (desired_speed * life) + 1 = firing_range
	scene.firing_range = (energy_data["speed"] / 10) * energy_data["life"] + 1

	scene.set_meta("source_folder", get_source_folder())

	var sound_file = File.new()
	if sound_file.file_exists(source_folder + "/sound.wav"):
		var audio_stream = load(source_folder + "/sound.wav")
		var audio_player = AudioStreamPlayer3D.new()
		audio_player.set_stream(audio_stream)
		audio_player.set_bus("Sound Effects")
		audio_player.set_autoplay(true)
		scene.add_child(audio_player)
		audio_player.set_owner(scene)
	else:
		print("sound.wav file not found at " + source_folder)

	return .post_import(scene)


const EnergyBolt = preload("EnergyBolt.gd")
