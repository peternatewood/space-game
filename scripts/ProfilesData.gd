extends Node

var current_profile: Dictionary
var profile_section_map: Dictionary


func _ready():
	var profile_directory: Directory = Directory.new()
	var profile_file: ConfigFile = ConfigFile.new()

	if profile_directory.file_exists(USER_PROFILE_PATH):
		profile_file.load(USER_PROFILE_PATH)
		for section_name in profile_file.get_sections():
			var profile_name: String = profile_file.get_value(section_name, "name")
			profile_section_map[profile_name] = section_name
	else:
		profile_file.save(USER_PROFILE_PATH)


# PUBLIC


func create_profile(profile_name: String):
	var profile_file: ConfigFile = ConfigFile.new()
	profile_file.load(USER_PROFILE_PATH)

	var profile_index: int = profile_file.get_sections().size()
	var section_name: String = "profile_" + str(profile_index)
	profile_section_map[profile_name] = section_name

	profile_file.set_value(section_name, "name", profile_name)
	profile_file.set_value(section_name, "campaign", "")
	profile_file.set_value(section_name, "mission", "")

	profile_file.save(USER_PROFILE_PATH)


func delete_profile(profile_to_delete: String):
	var profile_file: ConfigFile = ConfigFile.new()
	profile_file.load(USER_PROFILE_PATH)

	# Run through sections and rename profile sections that come after the deleted profile
	var move_sections: bool = false
	var section_index: int = -1

	for section_name in profile_file.get_sections():
		section_index += 1

		if move_sections:
			var profile_name: String = profile_file.get_value(section_name, "name")
			var profile_campaign: String = profile_file.get_value(section_name, "campaign")
			var profile_mission: String = profile_file.get_value(section_name, "mission")

			var new_section_name: String = "profile_" + str(section_index)

			profile_file.set_value(new_section_name, "name", profile_name)
			profile_file.set_value(new_section_name, "campaign", profile_campaign)
			profile_file.set_value(new_section_name, "mission", profile_mission)
		elif profile_file.get_value(section_name, "name") == profile_to_delete:
			profile_file.erase_section(section_name)
			section_index -= 1
			move_sections = true

	profile_file.save(USER_PROFILE_PATH)


func load_profile(profile_name: String):
	if profile_section_map.has(profile_name):
		var profile_file: ConfigFile = ConfigFile.new()
		profile_file.load(USER_PROFILE_PATH)

		var section_name: String = profile_section_map[profile_name]

		current_profile = {
			"name": profile_file.get_value(section_name, "name"),
			"campaign": profile_file.get_value(section_name, "campaign"),
			"mission": profile_file.get_value(section_name, "mission")
		}

		return true

	return false


const USER_PROFILE_PATH: String = "user://profiles.cfg"
