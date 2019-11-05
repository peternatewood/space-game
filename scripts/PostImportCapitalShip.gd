tool
extends "PostImportActor.gd"


func post_import(scene):
	var exhaust_mesh = scene.get_node("Exhaust")
	exhaust_mesh.set_surface_material(0, BLUE_EXHAUST_MATERIAL)
	exhaust_mesh.set_cast_shadows_setting(GeometryInstance.SHADOW_CASTING_SETTING_OFF)

	# Set exhaust billboard material
	var exhaust_points = scene.get_node("Exhaust Points")
	if exhaust_points != null:
		exhaust_points.set_surface_material(0, EXHAUST_LIGHT_MATERIAL)

	# Not all capital ships will have all types of turret
	var has_beam_weapons = scene.has_node("Beam Weapon Turrets")
	scene.set_meta("has_beam_weapon_turrets", has_beam_weapons)
	var has_energy_weapons = scene.has_node("Energy Weapon Turrets")
	scene.set_meta("has_energy_weapon_turrets", has_energy_weapons)
	var has_missile_weapons = scene.has_node("Missile Weapon Turrets")
	scene.set_meta("has_missile_weapon_turrets", has_missile_weapons)

	# Replace turret placeholders with turret instances
	if has_beam_weapons:
		pass

	if has_energy_weapons:
		var turrets_container = scene.get_node("Energy Weapon Turrets")
		for turret_placeholder in turrets_container.get_children():
			var turret_xform: Transform = turret_placeholder.transform
			turret_placeholder.free()

			var turret = ENERGY_WEAPON_TURRET.instance()
			turret.transform = turret_xform
			turrets_container.add_child(turret)
			turret.set_owner(scene)

	if has_missile_weapons:
		pass

	# This is used for loading the data file and other resources
	var source_folder = get_source_folder()
	var data_file = File.new()
	var data_file_name: String = source_folder + "/data.json"

	# Set defaults to be overridden by data file
	var max_speed: float = 7.0
	var ship_data: Dictionary = {
		"hull_hitpoints": 100.0,
		"ship_class": "ship"
	}

	if data_file.file_exists(data_file_name):
		data_file.open(data_file_name, File.READ)

		var data_parsed = JSON.parse(data_file.get_as_text())
		if data_parsed.error == OK:
			for key in ship_data.keys():
				var property = data_parsed.result.get(key)
				if property != null and typeof(property) == typeof(ship_data[key]):
					ship_data[key] = property

			var mass = data_parsed.result.get("mass")
			if mass != null and typeof(mass) == TYPE_REAL:
				scene.set_mass(mass)

			# Speed in data file is in m/s, so we have to divide by 10 to get actual value
			var parsed_max_speed = data_parsed.result.get("max_speed")
			if parsed_max_speed != null and typeof(parsed_max_speed) == TYPE_REAL:
				max_speed = parsed_max_speed / 10
		else:
			print("Error while parsing data file: ", data_file_name + " " + data_parsed.error_string)

		data_file.close()
	else:
		print("No such file: " + data_file_name)

	for key in ship_data.keys():
		scene.set_meta(key, ship_data[key])

	scene.set_meta("max_speed", max_speed)
	scene.set_meta("propulsion_force", MathHelper.get_propulsion_force_from_mass_and_speed(max_speed, scene.mass))
	scene.set_meta("source_file", get_source_file())
	scene.set_meta("source_folder", source_folder)

	return .post_import(scene)


const MathHelper = preload("MathHelper.gd")

const BLUE_EXHAUST_MATERIAL = preload("res://materials/blue_exhaust.tres")
const ENERGY_WEAPON_TURRET = preload("res://models/turrets/energy_weapon_turret/model.dae")
const EXHAUST_LIGHT_MATERIAL = preload("res://materials/exhaust_light.tres")
