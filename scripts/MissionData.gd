extends Node

var briefing: Array
var energy_weapon_models: Dictionary
var missile_weapon_models: Dictionary
var mission_name: String
var mission_scene_path: String
var objectives: Array
var ship_models: Dictionary
var wing_loadouts: Dictionary


func _ready():
	# Map ship and weapon models by name
	var dir = Directory.new()
	if dir.open("res://models/ships") != OK:
		print("Unable to open res://models/ships directory")
	else:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				var model_dir = dir.get_current_dir() + "/" + file_name + "/"
				var model_file = load(model_dir + "model.dae")

				var data_file = File.new()
				var data_file_error = data_file.open(model_dir + "data.json", File.READ)

				if data_file_error != OK:
					print("Unable to open data file in " + model_dir)
				else:
					var data_parsed = JSON.parse(data_file.get_as_text())

					if data_parsed.error != OK:
						print("Error parsing data file at " + model_dir + ": " + data_parsed.error_string)
					elif model_file == null:
						print("Unable to load model file at " + model_file)
					else:
						ship_models[data_parsed.result.get("ship_class", "ship")] = model_file

			file_name = dir.get_next()

	if dir.open("res://models/energy_weapons") != OK:
		print("Unable to open res://models/energy_weapons directory")
	else:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				var model_dir = dir.get_current_dir() + "/" + file_name + "/"
				var model_file = load(model_dir + "model.dae")

				var data_file = File.new()
				var data_file_error = data_file.open(model_dir + "data.json", File.READ)

				if data_file_error != OK:
					print("Unable to open data file in " + model_dir)
				else:
					var data_parsed = JSON.parse(data_file.get_as_text())

					if data_parsed.error != OK:
						print("Error parsing data file at " + model_dir + ": " + data_parsed.error_string)
					elif model_file == null:
						print("Unable to load model file at " + model_file)
					else:
						energy_weapon_models[data_parsed.result.get("name", "energy weapon")] = model_file

			file_name = dir.get_next()

	if dir.open("res://models/missile_weapons") != OK:
		print("Unable to open res://models/missile_weapons directory")
	else:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				var model_dir = dir.get_current_dir() + "/" + file_name + "/"
				var model_file = load(model_dir + "model.dae")

				var data_file = File.new()
				var data_file_error = data_file.open(model_dir + "data.json", File.READ)

				if data_file_error != OK:
					print("Unable to open data file in " + model_dir)
				else:
					var data_parsed = JSON.parse(data_file.get_as_text())

					if data_parsed.error != OK:
						print("Error parsing data file at " + model_dir + ": " + data_parsed.error_string)
					elif model_file == null:
						print("Unable to load model file at " + model_file)
					else:
						missile_weapon_models[data_parsed.result.get("name", "missile weapon")] = model_file

			file_name = dir.get_next()


# PUBLIC


func get_weapon_models(type: String, wing_name: String, ship_index: int):
	var models: Array = []
	for weapon_data in wing_loadouts[wing_name][ship_index][type]:
		models.append(weapon_data.model)

	return models


func load_mission_data(folder_name: String):
	var directory = "res://missions/" + folder_name + "/data.json"
	var data_file = File.new()

	if data_file.file_exists(directory):
		var file_error = data_file.open(directory, File.READ)
		if file_error == OK:
			var parse_result = JSON.parse(data_file.get_as_text())
			if parse_result.error == OK:
				# Get general mission info
				mission_name = parse_result.result.get("name", "mission_name")
				briefing = []
				for brief_copy in parse_result.result.get("briefing"):
					briefing.append(brief_copy)

				# Get loadout for each ship by wing
				var default_loadout = parse_result.result.get("default_loadout", {})
				for wing_name in VALID_WINGS:
					# Only load data for valid wing names, and type-check the data file
					if default_loadout.has(wing_name) and default_loadout[wing_name] is Array:
						wing_loadouts[wing_name] = []
						# More type checking
						var invalid_wing: bool = false
						for loadout in default_loadout[wing_name]:
							if not loadout is Dictionary:
								invalid_wing = true
								break

						if invalid_wing:
							continue

						for index in range(min(MAX_SHIPS_PER_WING, default_loadout[wing_name].size())):
							var ship_loadout: Dictionary = {
								"ship_class": "Frog Fighter",
								"model": ship_models["Frog Fighter"],
								"energy_weapons": [
									{ "name": "none", "model": null },
									{ "name": "none", "model": null },
									{ "name": "none", "model": null }
								],
								"missile_weapons": [
									{ "name": "none", "model": null },
									{ "name": "none", "model": null },
									{ "name": "none", "model": null },
									{ "name": "none", "model": null }
								]
							}

							var ship_class = default_loadout[wing_name][index].get("ship_class", "")
							if ship_models.has(ship_class):
								ship_loadout["ship_class"] = ship_class
								ship_loadout["model"] = ship_models[ship_class]

							var energy_weapon_index: int = 0
							for energy_weapon_name in default_loadout[wing_name][index].get("energy_weapons", []):
								if energy_weapon_name != "none" and energy_weapon_models.has(energy_weapon_name):
									ship_loadout["energy_weapons"][energy_weapon_index] = { "name": energy_weapon_name, "model": energy_weapon_models[energy_weapon_name] }

								energy_weapon_index += 1
								if energy_weapon_index >= ship_loadout["energy_weapons"].size():
									break

							var missile_weapon_index: int = 0
							for missile_weapon_name in default_loadout[wing_name][index].get("missile_weapons", []):
								if missile_weapon_name != "none" and missile_weapon_models.has(missile_weapon_name):
									ship_loadout["missile_weapons"][missile_weapon_index] = { "name": missile_weapon_name, "model": missile_weapon_models[missile_weapon_name] }

								missile_weapon_index += 1
								if missile_weapon_index >= ship_loadout["missile_weapons"].size():
									break

							wing_loadouts[wing_name].append(ship_loadout)

				# Get mission objectives
				objectives = [ [], [], [] ]
				var objective_data = parse_result.result.get("objectives", [])
				for index in range(min(3, objectives.size())):
					for objective in objective_data[index]:
						objectives[index].append(Objective.new(objective))

				mission_scene_path = "res://missions/" + folder_name + "/scene.tscn"
			else:
				print("Error parsing " + directory + ": " + parse_result.error_string)
		else:
			print("Error opening " + directory + ": " + str(file_error))
	else:
		print("Unable to open mission data file: no such file at " + directory)


const Objective = preload("Objective.gd")

const MAX_SHIPS_PER_WING: int = 4
const VALID_WINGS: Array = [ "Alpha", "Beta", "Gamma", "Delta", "Epsilon" ]
