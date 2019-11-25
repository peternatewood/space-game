extends Node

var armory: Dictionary
var beam_weapon_models: Dictionary
var briefing: Array
var capital_ship_models: Dictionary
var energy_weapon_models: Dictionary
var missile_weapon_models: Dictionary
var mission_name: String
var mission_scene_path: String
var non_player_loadouts: Dictionary
var objectives: Array
var ship_models: Dictionary
var wing_loadouts: Array = []
var wing_names: Array = []


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
						print("Unable to load model file at " + model_dir)
					else:
						ship_models[data_parsed.result.get("ship_class", "ship")] = model_file

				data_file.close()

			file_name = dir.get_next()

	# Also load capital ships
	if dir.open("res://models/capital_ships") != OK:
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
						print("Unable to load model file at " + model_dir)
					else:
						capital_ship_models[data_parsed.result.get("ship_class", "ship")] = model_file

				data_file.close()

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

				data_file.close()

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

				data_file.close()

			file_name = dir.get_next()


# PUBLIC


func get_weapon_models(type: String, wing_index: int, ship_index: int):
	var models: Array = []
	for weapon_data in wing_loadouts[wing_index][ship_index][type]:
		models.append(weapon_data.model)

	return models


# Loads mission data from file; returns true if successful, false if not
func load_mission_data(path: String):
	var file = File.new()

	if file.file_exists(path):
		var mission_scene = load(path)
		var mission_instance = mission_scene.instance()

		# Check for required meta data
		var missing_meta: bool = false
		for meta_name in REQUIRED_MISSION_META:
			if not mission_instance.has_meta(meta_name):
				print("Missing meta data: " + meta_name)
				missing_meta = true

		if missing_meta:
			return false

		mission_name = mission_instance.get_meta("name")
		briefing = mission_instance.get_meta("briefing")
		armory = mission_instance.get_meta("armory")
		wing_names = mission_instance.get_meta("wing_names")

		# Get loadout for each ship by wing
		wing_loadouts = []

		var default_loadouts = mission_instance.get_meta("default_loadouts")
		var wing_index: int = 0
		for loadout in default_loadouts:
			wing_loadouts.append([])

			for index in range(min(MAX_SHIPS_PER_WING, loadout.size())):
				var ship = mission_instance.get_node("Targets Container/" + loadout[index].name)
				var ship_class = ship.get_meta("ship_class")

				var ship_loadout: Dictionary = {
					"ship_class": ship_class,
					"model": ship_models[ship_class],
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

				var energy_weapon_index: int = 0
				for energy_weapon_name in loadout[index].get("energy_weapons", []):
					if energy_weapon_name != "none" and energy_weapon_models.has(energy_weapon_name) and armory.energy_weapons.has(energy_weapon_name):
						ship_loadout["energy_weapons"][energy_weapon_index] = { "name": energy_weapon_name, "model": energy_weapon_models[energy_weapon_name] }

					energy_weapon_index += 1
					if energy_weapon_index >= ship_loadout["energy_weapons"].size():
						break

				var missile_weapon_index: int = 0
				for missile_weapon_name in loadout[index].get("missile_weapons", []):
					if missile_weapon_name != "none" and missile_weapon_models.has(missile_weapon_name) and armory.missile_weapons.has(missile_weapon_name):
						ship_loadout["missile_weapons"][missile_weapon_index] = { "name": missile_weapon_name, "model": missile_weapon_models[missile_weapon_name] }

					missile_weapon_index += 1
					if missile_weapon_index >= ship_loadout["missile_weapons"].size():
						break

				wing_loadouts[wing_index].append(ship_loadout)

			wing_index += 1

		# Get the loadouts for all non-player-accessible ships
		var meta_loadouts = mission_instance.get_meta("non_player_loadouts")
		non_player_loadouts = {}
		for ship_name in meta_loadouts.keys():
			non_player_loadouts[ship_name] = {
				"beam_weapons": [],
				"energy_weapons": [],
				"missile_weapons": []
			}

			for beam_weapon_name in meta_loadouts[ship_name].get("beam_weapons", []):
				if beam_weapon_models.has(beam_weapon_name):
					non_player_loadouts[ship_name].beam_weapons.append(beam_weapon_models[beam_weapon_name])

			for energy_weapon_name in meta_loadouts[ship_name].get("energy_weapons", []):
				if energy_weapon_models.has(energy_weapon_name):
					non_player_loadouts[ship_name].energy_weapons.append(energy_weapon_models[energy_weapon_name])

			for missile_weapon_name in meta_loadouts[ship_name].get("missile_weapons", []):
				if missile_weapon_models.has(missile_weapon_name):
					non_player_loadouts[ship_name].missile_weapons.append(missile_weapon_models[missile_weapon_name])

		# Get mission objectives
		objectives = [ [], [], [] ]
		var objective_data = mission_instance.get_meta("objectives")
		for index in range(min(3, objectives.size())):
			for objective in objective_data[index]:
				objectives[index].append(Objective.new(objective))

		# Take a second pass to connect any objectives that require another objective to succeed/fail
		for index in range(min(3, objectives.size())):
			for objective in objectives[index]:
				for success in objective.success_requirements:
					match success.type:
						Objective.OBJECTIVE:
							if success.objective_index != -1 and success.objective_type != -1:
								objectives[success.objective_type][success.objective_index].connect("completed", success, "_on_objective_completed")
								objectives[success.objective_type][success.objective_index].connect("failed", success, "_on_objective_failed")

				# And for failure requirements
				for failure in objective.failure_requirements:
					match failure.type:
						Objective.OBJECTIVE:
							if failure.objective_index != -1 and failure.objective_type != -1:
								objectives[failure.objective_type][failure.objective_index].connect("completed", failure, "_on_objective_completed")
								objectives[failure.objective_type][failure.objective_index].connect("failed", failure, "_on_objective_failed")

		mission_scene_path = path

	else:
		print("Invalid path: " + path)
		return false

	return true


const Objective = preload("Objective.gd")

const MAX_SHIPS_PER_WING: int = 4
const REQUIRED_MISSION_META: Array = [
	"armory",
	"briefing",
	"default_loadouts",
	"name",
	"non_player_loadouts",
	"objectives",
	"player_path",
	"reinforcement_wings",
	"wing_names"
]
const VALID_WINGS: Array = [ "Alpha", "Beta", "Gamma", "Delta", "Epsilon" ]
