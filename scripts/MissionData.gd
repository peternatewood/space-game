extends Node

onready var profiles_data = get_node("/root/ProfilesData")

var armory: Dictionary = {}
var beam_weapon_data: Dictionary = {}
var briefing: Array = []
var campaign_data: Dictionary = {}
var custom_campaign_list: Array = []
var default_campaign_list: Array = []
var default_ship_directory: String = "spider_fighter"
var default_beam_weapon_directory: String = "argon_beam"
var default_energy_weapon_directory: String = "energy_bolt"
var default_missile_weapon_directory: String = "heat_seeker"
var energy_weapon_data: Dictionary = {}
var is_in_campaign: bool = false
var missile_weapon_data: Dictionary = {}
var mission_name: String
var mission_scene_path: String
var non_player_loadouts: Dictionary = {}
var objectives: Array = []
var original_title: String = ProjectSettings.get_setting("application/config/name")
var ship_data: Dictionary = {}
var wing_loadouts: Array = []
var wing_names: Array = []


func _ready():
	var dir: Directory = Directory.new()

	# Map ship and weapon models by name
	var ships_config: ConfigFile = ConfigFile.new()
	ships_config.load("res://configs/ships.cfg")

	for section in ships_config.get_sections():
		var is_data_good: bool = true

		# Fall back on Spider Fighter for any missing data
		var model_dir: String = "res://models/ships/" + default_ship_directory +"/"
		if dir.dir_exists("res://models/ships/" + section + "/"):
			model_dir = "res://models/ships/" + section + "/"
		else:
			print("Warning: missing directory for ship model " + section + ". The default directory will be used instead: ", model_dir)

		var ship_class: String = ships_config.get_value(section, "ship_class")
		if ship_class == null:
			print("Missing ship_class for: ", section, " config!")
			continue

		if ship_data.has(ship_class):
			print("Ship data already loaded for class: ", ship_class)
			continue

		var model_path: String = "res://models/ships/" + default_ship_directory + "/model.dae"
		if dir.file_exists(model_path):
			model_path = model_dir + "model.dae"
		else:
			print("Warning: missing ship model file. The default model will be used instead: ", model_path)

		var ship_config_data: Dictionary = {
			"model_dir": model_dir,
			"model_path": model_path,
			"energy_weapon_slots": 0,
			"missile_weapon_slots": 0,
			"beam_weapon_turrets": 0,
			"energy_weapon_turrets": 0,
			"missile_weapon_turrets": 0
		}

		var model = load(model_path)
		if model == null:
			print("Unable to load ship model: ", ship_class)
			is_data_good = false
		else:
			var ship_instance = model.instance()

			# Stuff that's only for capital ships or small ships
			if ship_instance.get_meta("is_capital_ship"):
				if ship_instance.has_node("Beam Weapon Turrets"):
					ship_config_data.beam_weapon_turrets = ship_instance.get_node("Beam Weapon Turrets").get_child_count()
				if ship_instance.has_node("Energy Weapon Turrets"):
					ship_config_data.energy_weapon_turrets = ship_instance.get_node("Energy Weapon Turrets").get_child_count()
				if ship_instance.has_node("Missile Weapon Turrets"):
					ship_config_data.missile_weapon_turrets = ship_instance.get_node("Missile Weapon Turrets").get_child_count()
			else:
				var icon_path: String = model_dir + "icon.png"
				if not dir.file_exists(icon_path):
					icon_path = "res://models/ships/" + default_ship_directory + "/icon.png"
					print("Warning: missing icon for ", ship_class, ". The default icon will be used instead: ", icon_path)

				var loadout_overhead_path: String = model_dir + "loadout_overhead.png"
				if not dir.file_exists(loadout_overhead_path):
					loadout_overhead_path = "res://models/ships/" + default_ship_directory + "/loadout_overhead.png"
					print("Warning: missing loadout overhead for ", ship_class, ". The default loadout overhead will be used instead: ", loadout_overhead_path)

				ship_config_data["icon_path"] = icon_path
				ship_config_data["loadout_overhead_path"] = loadout_overhead_path

				var energy_weapon_groups = ship_instance.get_node_or_null("Energy Weapon Groups")
				var missile_weapon_groups = ship_instance.get_node_or_null("Missile Weapon Groups")

				if energy_weapon_groups == null:
					print("Missing energy weapon groups for ", ship_class)
				else:
					ship_config_data.energy_weapon_slots = energy_weapon_groups.get_child_count()

				if missile_weapon_groups == null:
					print("Missing missile weapon groups for ", ship_class)
				else:
					ship_config_data.missile_weapon_slots = missile_weapon_groups.get_child_count()

			ship_instance.free()

		for key in ships_config.get_section_keys(section):
			ship_config_data[key] = ships_config.get_value(section, key)

		if is_data_good:
			ship_data[ship_class] = ship_config_data

	var weapons_config: ConfigFile = ConfigFile.new()
	weapons_config.load("res://configs/weapons.cfg")

	for section in weapons_config.get_sections():
		var is_data_good: bool = true

		var weapon_name = weapons_config.get_value(section, "name")
		if weapon_name == null:
			print("Missing weapon name for ", section, " config!")
			continue

		var model_dir: String

		match weapons_config.get_value(section, "type"):
			"beam_weapon":
				if beam_weapon_data.has(section):
					print("Beam weapon data already loaded for name: ", weapon_name)
					is_data_good = false

				model_dir = "res://models/beam_weapons/" + default_beam_weapon_directory + "/"
				if dir.dir_exists("res://models/beam_weapons/" + section + "/"):
					model_dir = "res://models/beam_weapons/" + section + "/"
				else:
					print("Warning: missing directory for beam weapon model " + weapon_name + ". The default directory will be used instead: ", model_dir)

				var model_path: String = model_dir + "model.tscn"
				if dir.file_exists(model_path):
					model_path = model_dir + "model.tscn"
				else:
					print("Warning: missing beam weapon model file for " + weapon_name + ". The default model will be used instead: ", model_path)

				var video_path: String = model_dir + "video.ogv"
				if not dir.file_exists(video_path):
					video_path = "res://models/beam_weapon/" + default_beam_weapon_directory + "/video.ogv"
					print("Warning: missing video for ", weapon_name, ". The default video will be used instead: ", video_path)

				var beam_weapon_config_data: Dictionary = {
					"model_dir": model_dir,
					"model_path": model_path,
					"video_path": video_path
				}

				for key in weapons_config.get_section_keys(section):
					beam_weapon_config_data[key] = weapons_config.get_value(section, key)

				var beam_weapon_model = load(beam_weapon_config_data.model_path)
				if beam_weapon_model == null:
					print("Unable to load beam weapon model: ", weapon_name)
				else:
					var beam_instance = beam_weapon_model.instance()

					beam_weapon_config_data["fire_delay"] = beam_instance.fire_delay
					beam_weapon_config_data["fire_duration"] = beam_instance.fire_duration
					beam_weapon_config_data["damage_hull"] = beam_instance.hull_damage
					beam_weapon_config_data["damage_shield"] = beam_instance.shield_damage

					beam_instance.free()

				if is_data_good:
					beam_weapon_data[weapon_name] = beam_weapon_config_data
			"energy_weapon":
				model_dir = "res://models/energy_weapons/" + default_energy_weapon_directory + "/"
				if dir.dir_exists("res://models/energy_weapons/" + section + "/"):
					model_dir = "res://models/energy_weapons/" + section + "/"
				else:
					print("Warning: missing directory for energy weapon model " + weapon_name + ". The default directory will be used instead: ", model_dir)

				var model_path: String = model_dir + "model.dae"
				if dir.file_exists(model_path):
					model_path = model_dir + "model.dae"
				else:
					print("Warning: missing energy weapon model file for " + weapon_name + ". The default model will be used instead: ", model_path)

				var icon_path: String = model_dir + "icon.png"
				if not dir.file_exists(icon_path):
					icon_path = "res://models/energy_weapons/" + default_energy_weapon_directory + "/icon.png"
					print("Warning: missing icon for ", weapon_name, ". The default icon will be used instead: ", icon_path)

				var video_path: String = model_dir + "video.ogv"
				if not dir.file_exists(video_path):
					video_path = "res://models/energy_weapons/" + default_energy_weapon_directory + "/video.ogv"
					print("Warning: missing video for ", weapon_name, ". The default video will be used instead: ", video_path)

				var energy_weapon_config_data: Dictionary = {
					"icon_path": icon_path,
					"model_dir": model_dir,
					"model_path": model_path,
					"video_path": video_path
				}

				for key in weapons_config.get_section_keys(section):
					energy_weapon_config_data[key] = weapons_config.get_value(section, key)

				energy_weapon_data[weapon_name] = energy_weapon_config_data
			"missile_weapon":
				model_dir = "res://models/energy_weapons/" + default_missile_weapon_directory + "/"
				if dir.dir_exists("res://models/missile_weapons/" + section + "/"):
					model_dir = "res://models/missile_weapons/" + section + "/"
				else:
					print("Warning: missing directory for missile weapon model " + weapon_name + ". The default directory will be used instead: ", model_dir)

				var model_path: String = model_dir + "model.dae"
				if dir.file_exists(model_path):
					model_path = model_dir + "model.dae"
				else:
					print("Warning: missing missile weapon model file for " + weapon_name + ". The default model will be used instead: ", model_path)

				var icon_path: String = model_dir + "icon.png"
				if not dir.file_exists(icon_path):
					icon_path = "res://models/missile_weapons/" + default_missile_weapon_directory + "/icon.png"
					print("Warning: missing icon for ", weapon_name, ". The default icon will be used instead: ", icon_path)

				var video_path: String = model_dir + "video.ogv"
				if not dir.file_exists(video_path):
					video_path = "res://models/missile_weapons/" + default_missile_weapon_directory + "/video.ogv"
					print("Warning: missing video for ", weapon_name, ". The default video will be used instead: ", video_path)

				var missile_weapon_config_data = {
					"icon_path": icon_path,
					"model_dir": model_dir,
					"model_path": model_path,
					"video_path": video_path
				}

				for key in weapons_config.get_section_keys(section):
					missile_weapon_config_data[key] = weapons_config.get_value(section, key)

				missile_weapon_data[weapon_name] = missile_weapon_config_data

	# Build campaign list
	if !dir.dir_exists("res://campaigns"):
		print("Missin res://campaigns directory!")
	else:
		var campaigns_config: ConfigFile = ConfigFile.new()
		campaigns_config.load("res://configs/campaigns.cfg")

		for file_name in campaigns_config.get_value("list", "config_files", []):
			var campaign_file: ConfigFile = ConfigFile.new()
			var campaign_path: String = "res://campaigns/" + file_name

			if !dir.file_exists(campaign_path):
				print("No such file exists: ", campaign_path)
				continue

			campaign_file.load(campaign_path)

			var default_campaign_data: Dictionary = {
				"path": campaign_path,
				"name": campaign_file.get_value("details", "name"),
				"description": campaign_file.get_value("details", "description")
			}

			default_campaign_list.append(default_campaign_data)

	# Build custom campaign list
	if dir.open(USER_CAMPAIGNS_DIR) != OK:
		print("Unable to open " + USER_CAMPAIGNS_DIR + " directory")
	else:
		var campaign_file: ConfigFile = ConfigFile.new()

		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".cfg"):
				var campaign_path: String = dir.get_current_dir() + "/" + file_name
				campaign_file.load(campaign_path)

				var custom_campaign_data: Dictionary = {
					"path": campaign_path,
					"name": campaign_file.get_value("details", "name"),
					"description": campaign_file.get_value("details", "description")
				}

				custom_campaign_list.append(custom_campaign_data)

			file_name = dir.get_next()


# PUBLIC


func get_next_mission_path():
	var next_mission_path

	for mission_data in campaign_data.missions:
		if mission_data.path == mission_scene_path:
			var next_mission_index: int = -1
			var next_missions: Array = mission_data.get("next_missions", [])

			for index in range(next_missions.size()):
				# Assume this mission's requirements are met: if a mission's objectives array is empty or missing, it has no requirements
				var requirements_met: bool = true
				for objective in next_missions[index].get("objectives", []):
					var objective_type: int = objective.get("objective_type", -1)
					var objective_index: int = objective.get("objective_index", -1)

					if objective_type != -1 and objective_index != -1:
						if objectives[objective_type][objective_index].state != Objective.COMPLETED:
							requirements_met = false
							break

				if requirements_met:
					next_mission_index = next_missions[index].get("index", -1)
					break

			if next_mission_index != -1:
				return campaign_data.missions[next_mission_index].path

			return null

	return null


func get_weapon_models(type: String, wing_index: int, ship_index: int):
	var models: Array = []
	for weapon_data in wing_loadouts[wing_index][ship_index][type]:
		models.append(weapon_data.model)

	return models


func get_unlocked_missions():
	return profiles_data.current_profile.unlocked_missions


func has_profile_started_campaign():
	return profiles_data.current_profile.campaign != ""


func load_campaign_data(path: String, save_to_profile: bool = false):
	var campaign_directory: Directory = Directory.new()
	var campaign_file: ConfigFile = ConfigFile.new()

	if campaign_directory.file_exists(path):
		var load_error = campaign_file.load(path)

		if load_error == OK:
			campaign_data["name"] = campaign_file.get_value("details", "name")
			campaign_data["description"] = campaign_file.get_value("details", "description")
			campaign_data["missions"] = campaign_file.get_value("mission_tree", "missions")

			if save_to_profile:
				profiles_data.set_campaign(path)
		else:
			print("Error loading campaign file ", path, ": ", load_error)
	else:
		print("Unable to find campaign file at: ", path)


func load_current_profile_mission():
	is_in_campaign = true
	load_campaign_data(profiles_data.current_profile.campaign)
	load_mission_data(profiles_data.current_profile.mission)


# Loads mission data from file; returns true if successful, false if not
func load_mission_data(path: String, save_to_profile: bool = false):
	var file = File.new()

	if file.file_exists(path):
		var mission_scene = load(path)
		var mission_instance = mission_scene.instance()

		if save_to_profile:
			profiles_data.set_mission(path)
			profiles_data.unlock_mission(path)

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

		# These are so we only load each model we need once
		var ship_models: Dictionary = {}
		var energy_weapon_models: Dictionary = {}
		var missile_weapon_models: Dictionary = {}

		var default_loadouts = mission_instance.get_meta("default_loadouts")
		var wing_index: int = 0
		for loadout in default_loadouts:
			wing_loadouts.append([])

			for index in range(min(MAX_SHIPS_PER_WING, loadout.size())):
				var ship = mission_instance.get_node("Targets Container/" + loadout[index].name)
				var ship_class = ship.get_meta("ship_class")

				if not ship_models.has(ship_class):
					ship_models[ship_class] = load(ship_data[ship_class].model_path)

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
					if energy_weapon_name != "none" and energy_weapon_data.has(energy_weapon_name) and armory.energy_weapons.has(energy_weapon_name):
						if not energy_weapon_models.has(energy_weapon_name):
							energy_weapon_models[energy_weapon_name] = load(energy_weapon_data[energy_weapon_name].model_path)

						ship_loadout["energy_weapons"][energy_weapon_index] = { "name": energy_weapon_name, "model": energy_weapon_models[energy_weapon_name] }

					energy_weapon_index += 1
					if energy_weapon_index >= ship_loadout["energy_weapons"].size():
						break

				var missile_weapon_index: int = 0
				for missile_weapon_name in loadout[index].get("missile_weapons", []):
					if missile_weapon_name != "none" and missile_weapon_data.has(missile_weapon_name) and armory.missile_weapons.has(missile_weapon_name):
						if not missile_weapon_models.has(missile_weapon_name):
							missile_weapon_models[missile_weapon_name] = load(missile_weapon_data[missile_weapon_name].model_path)

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
				if beam_weapon_data.has(beam_weapon_name):
					var beam_weapon_model = load(beam_weapon_data[beam_weapon_name].model_path)
					non_player_loadouts[ship_name].beam_weapons.append(beam_weapon_model)

			for energy_weapon_name in meta_loadouts[ship_name].get("energy_weapons", []):
				if energy_weapon_data.has(energy_weapon_name):
					var energy_weapon_model = load(energy_weapon_data[energy_weapon_name].model_path)
					non_player_loadouts[ship_name].energy_weapons.append(energy_weapon_model)

			for missile_weapon_name in meta_loadouts[ship_name].get("missile_weapons", []):
				if missile_weapon_data.has(missile_weapon_name):
					var missile_weapon_model = load(missile_weapon_data[missile_weapon_name].model_path)
					non_player_loadouts[ship_name].missile_weapons.append(missile_weapon_model)

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
const USER_CAMPAIGNS_DIR: String = "user://campaigns"
const USER_MISSIONS_DIR: String = "user://missions"
const VALID_WINGS: Array = [ "Alpha", "Beta", "Gamma", "Delta", "Epsilon" ]
