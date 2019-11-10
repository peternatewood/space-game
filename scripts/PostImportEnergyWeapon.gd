tool
extends "res://scripts/PostImportActor.gd"


func post_import(scene):
	# TODO: This doesn't actually change the materials on import. Not sure why
	var shell = scene.get_node("Shell")
	shell.mesh.surface_get_material(0).set_blend_mode(SpatialMaterial.BLEND_MODE_ADD)
	shell.mesh.surface_get_material(0).set_flag(SpatialMaterial.FLAG_DONT_RECEIVE_SHADOWS, true)

	var core = scene.get_node("Core")
	core.mesh.surface_get_material(0).set_flag(SpatialMaterial.FLAG_DONT_RECEIVE_SHADOWS, true)
	core.mesh.surface_get_material(0).set_flag(SpatialMaterial.FLAG_DISABLE_AMBIENT_LIGHT, true)

	# This is used for loading the data file and other resources
	var source_folder = get_source_folder()
	var data_file = File.new()
	var data_file_name: String = source_folder + "/data.json"

	# Set defaults to be overridden by data file
	var energy_data: Dictionary = {
		"cost": 1.0,
		"damage_hull": 10.0,
		"damage_shield": 5.0,
		"fire_delay": 1.0,
		"life": 4.0,
		"mass": 0.2,
		"speed": 40.0,
		"weapon_name": "energy_weapon"
	}

	if data_file.file_exists(data_file_name):
		data_file.open(data_file_name, File.READ)

		var data_parsed = JSON.parse(data_file.get_as_text())
		if data_parsed.error == OK:
			for key in energy_data.keys():
				var property = data_parsed.result.get(key)
				if property != null and typeof(property) == typeof(energy_data[key]):
					energy_data[key] = property

			var weapon_name = data_parsed.result.get("name")
			if weapon_name != null and typeof(weapon_name) == TYPE_STRING:
				energy_data["weapon_name"] = weapon_name
		else:
			print("Error while parsing data file: ", data_file_name + " " + data_parsed.error_string)

		data_file.close()
	else:
		print("No such file: " + data_file_name)

	scene.set_meta("source_folder", get_source_folder())

	scene.set_meta("cost", energy_data["cost"])
	scene.set_meta("damage_hull", energy_data["damage_hull"])
	scene.set_meta("damage_shield", energy_data["damage_shield"])
	scene.set_meta("fire_delay", energy_data["fire_delay"])
	scene.set_meta("life", energy_data["life"])
	# Convert m/s speed from data file to "speed" property that goes to add_central_force
	scene.set_meta("firing_force", MathHelper.get_force_from_mass_and_speed(energy_data["mass"], energy_data["speed"]))
	scene.set_meta("weapon_name", energy_data["weapon_name"])

	# From testing it seems like (desired_speed * life) + 1 = firing_range
	scene.set_meta("firing_range", (energy_data["speed"] / 10) * energy_data["life"] + 1)

	scene.set_mass(energy_data["mass"])

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

	scene.set_script(EnergyBolt)

	return .post_import(scene)


const EnergyBolt = preload("EnergyBolt.gd")
const MathHelper = preload("MathHelper.gd")
