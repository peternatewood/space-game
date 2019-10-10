tool
extends "res://scripts/PostImportActor.gd"


func post_import(scene):
	# Note: the imported model's material is on the mesh property, not the MeshInstance node
	for node in scene.get_children():
		if node is MeshInstance:
			node.mesh.surface_get_material(0).flags_unshaded = true
			node.mesh.surface_get_material(0).flags_do_not_receive_shadows = true
			node.mesh.surface_get_material(0).flags_disable_ambient_light = true

	# This is used for loading the data file and other resources
	var source_folder = get_source_folder()
	var data_file = File.new()
	var data_file_name: String = source_folder + "/data.json"

	# Set defaults to be overridden by data file
	var energy_data: Dictionary = {
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
			var damage_hull = data_parsed.result.get("damage_hull")
			if damage_hull != null and typeof(damage_hull) == TYPE_REAL:
				energy_data["damage_hull"] = damage_hull

			var damage_shield = data_parsed.result.get("damage_shield")
			if damage_shield != null and typeof(damage_shield) == TYPE_REAL:
				energy_data["damage_shield"] = damage_shield

			var fire_delay = data_parsed.result.get("fire_delay")
			if fire_delay != null and typeof(fire_delay) == TYPE_REAL:
				energy_data["fire_delay"] = fire_delay

			var life = data_parsed.result.get("life")
			if life != null and typeof(life) == TYPE_REAL:
				energy_data["life"] = life

			var mass = data_parsed.result.get("mass")
			if mass != null and typeof(mass) == TYPE_REAL:
				energy_data["mass"] = mass

			var speed = data_parsed.result.get("speed")
			if speed != null and typeof(speed) == TYPE_REAL:
				energy_data["speed"] = speed

			var weapon_name = data_parsed.result.get("name")
			if weapon_name != null and typeof(weapon_name) == TYPE_STRING:
				energy_data["weapon_name"] = weapon_name
		else:
			print("Error while parsing data file: ", data_file_name + " " + data_parsed.error_string)
	else:
		print("No such file: " + data_file_name)

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
	scene.set_script(EnergyBolt)

	return .post_import(scene)


const EnergyBolt = preload("EnergyBolt.gd")
const MathHelper = preload("MathHelper.gd")
