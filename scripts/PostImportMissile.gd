tool
extends "res://scripts/PostImportCollision.gd"


func post_import(scene):
	scene.set_script(Missile)

	# This is used for loading the data file and other resources
	var source_folder = get_source_folder()
	var weapons_config: ConfigFile = ConfigFile.new()
	weapons_config.load("res://configs/weapons.cfg")

	# Set defaults to be overridden by data file
	var missile_data: Dictionary = {
		"acceleration": 1.0,
		"ammo_cost": 2.0,
		"damage_hull": 10.0,
		"damage_shield": 5.0,
		"damage_subsystem": 1.5,
	  "fire_delay": 1.5,
	  "life": 10.0,
		"max_speed": 100.0,
		"search_radius": 10.0,
		"turn_speed": 1.0,
		"weapon_name": "missile"
	}

	for section in weapons_config.get_sections():
		if source_folder.ends_with(section):
			for key in weapons_config.get_section_keys(section):
				if missile_data.has(key):
					var property = weapons_config.get_value(section, key)
					if typeof(property) == typeof(missile_data[key]):
						missile_data[key] = property

			missile_data["weapon_name"] = weapons_config.get_value(section, "name")
			break

	for key in missile_data.keys():
		scene.set(key, missile_data[key])

	scene.set_meta("source_folder", get_source_folder())

	# Avg speed when accelerating: (max_speed - acceleration) / 2 | Seconds to reach max speed: max_speed / acceleration | Add max speed multiplied by remaining seconds
	# Avg accel speed: (100 - 20) / 2 = 40 | Seconds to max speed: 100 / 20 = 5
	# 40 * 5 + 100 * (12 - 5)
	var seconds_to_max: float = missile_data["max_speed"] / missile_data["acceleration"]
	var firing_range: float = ((missile_data["max_speed"] - missile_data["acceleration"]) / 2) * seconds_to_max + missile_data["max_speed"] * (missile_data["life"] - seconds_to_max)

	scene.firing_range = firing_range

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


const Missile = preload("Missile.gd")
