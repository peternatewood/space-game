extends Node

var mission_scene_path: String
var wing_loadouts: Dictionary


func load_mission_data(folder_name: String):
	var directory = "res://missions/" + folder_name + "/data.json"
	var data_file = File.new()

	if data_file.file_exists(directory):
		var file_error = data_file.open(directory, File.READ)
		if file_error == OK:
			var parse_result = JSON.parse(data_file.get_as_text())
			if parse_result.error == OK:
				var mission_name = parse_result.result.get("name", "mission_name")
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
								"ship_class": default_loadout[wing_name][index].get("ship_class", "Frog Fighter"),
								"energy_weapons": default_loadout[wing_name][index].get("energy_weapons", [ "Energy Bolt", "Energy Bolt" ]),
								"missile_weapons": default_loadout[wing_name][index].get("missile_weapons", [ "Heat Seeker" ])
							}
							wing_loadouts[wing_name].append(ship_loadout)

				mission_scene_path = "res://missions/" + folder_name + "/scene.tscn"
			else:
				print("Error parsing " + directory + ": " + parse_result.error_string)
		else:
			print("Error opening " + directory + ": " + str(file_error))
	else:
		print("Unable to open mission data file: no such file at " + directory)


const MAX_SHIPS_PER_WING: int = 4
const VALID_WINGS: Array = [ "Alpha", "Beta", "Gamma", "Delta", "Epsilon" ]
