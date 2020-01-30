tool
extends "res://scripts/PostImportCollision.gd"


func post_import(scene):
	scene.set_script(EnergyBolt)

	# This is used for loading the data file and other resources
	var source_folder = get_source_folder()
	var weapons_config: ConfigFile = ConfigFile.new()
	weapons_config.load("res://configs/weapons.cfg")

	# Set defaults to be overridden by data file
	var energy_data: Dictionary = {
		"cost": 1.0,
		"damage_hull": 10.0,
		"damage_shield": 5.0,
		"damage_subsystem": 2.0,
		"fire_delay": 1.0,
		"life": 4.0,
		"speed": 40.0,
		"weapon_name": "energy_weapon"
	}

	for section in weapons_config.get_sections():
		if source_folder.ends_with(section):
			for key in weapons_config.get_section_keys(section):
				if energy_data.has(key):
					var property = weapons_config.get_value(section, key)
					if typeof(property) == typeof(energy_data[key]):
						energy_data[key] = property

			energy_data["weapon_name"] = weapons_config.get_value(section, "name")
			break

	for key in energy_data.keys():
		scene.set(key, energy_data[key])

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
