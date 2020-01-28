extends Node

var current_profile: Dictionary
var name_path_map: Dictionary = {}


func _ready():
	var profile_directory: Directory = Directory.new()
	var profile_config: ConfigFile = ConfigFile.new()

	if not profile_directory.dir_exists(PROFILE_DIRECTORY):
		profile_directory.make_dir(PROFILE_DIRECTORY)

	if not profile_directory.file_exists(PROFILE_CONFIG_PATH):
		profile_config.set_value("data", "name_path_map", name_path_map)
		profile_config.save(PROFILE_CONFIG_PATH)

	profile_config.load(PROFILE_CONFIG_PATH)
	name_path_map = profile_config.get_value("data", "name_path_map")


# PUBLIC


func create_profile(profile_name: String):
	var safe_file_name: String = profile_name.get_file().to_lower()

	for name in name_path_map.keys():
		if name.get_file().to_lower() == safe_file_name:
			return false

	var profile_path: String = PROFILE_DIRECTORY + "/" + safe_file_name + ".cfg"

	var profile_file: ConfigFile = ConfigFile.new()
	profile_file.load(profile_path)

	profile_file.set_value("data", "name", profile_name)
	profile_file.set_value("data", "campaign", "")
	profile_file.set_value("data", "mission", "")
	profile_file.set_value("data", "unlocked_missions", [])

	profile_file.save(profile_path)

	name_path_map[profile_name] = profile_path
	var profile_config: ConfigFile = ConfigFile.new()
	profile_config.load(PROFILE_CONFIG_PATH)
	profile_config.set_value("data", "name_path_map", name_path_map)

	profile_config.save(PROFILE_CONFIG_PATH)

	return true


func delete_profile(profile_to_delete: String):
	if name_path_map.has(profile_to_delete):
		var dir_manager: Directory = Directory.new()
		dir_manager.remove(name_path_map[profile_to_delete])
		name_path_map.erase(profile_to_delete)

		return true

	return false


func get_profile_names():
	return name_path_map.keys()


func load_profile(profile_name: String):
	if name_path_map.has(profile_name):
		var profile_file: ConfigFile = ConfigFile.new()
		profile_file.load(name_path_map[profile_name])

		var unlocked_missions = profile_file.get_value("data", "unlocked_missions")
		if not unlocked_missions is Array:
			unlocked_missions = []

		current_profile = {
			"name": profile_file.get_value("data", "name"),
			"campaign": profile_file.get_value("data", "campaign"),
			"mission": profile_file.get_value("data", "mission"),
			"unlocked_missions": unlocked_missions
		}

		return true

	return false


func set_campaign(path: String):
	var profile_file: ConfigFile = ConfigFile.new()
	profile_file.load(name_path_map[current_profile.name])
	profile_file.set_value("data", "campaign", path)
	profile_file.save(name_path_map[current_profile.name])


func set_mission(path: String):
	var profile_file: ConfigFile = ConfigFile.new()

	profile_file.load(name_path_map[current_profile.name])
	profile_file.set_value("data", "mission", path)
	profile_file.save(name_path_map[current_profile.name])


func unlock_mission(path: String):
	if not current_profile.unlocked_missions.has(path):
		var profile_file: ConfigFile = ConfigFile.new()
		profile_file.load(name_path_map[current_profile.name])
		current_profile.unlocked_missions.append(path)
		profile_file.set_value("data", "unlocked_missions", current_profile.unlocked_missions)

		profile_file.save(name_path_map[current_profile.name])


const PROFILE_CONFIG_PATH: String = "user://profiles.cfg"
const PROFILE_DIRECTORY: String = "user://profiles"
