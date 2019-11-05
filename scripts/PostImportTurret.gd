tool
extends "PostImportActor.gd"


func post_import(scene):
	# This is used for loading the data file and other resources
	var source_folder = get_source_folder()
	var data_file = File.new()
	var data_file_name: String = source_folder + "/data.json"

	# Set defaults to be overridden by data file
	var turret_type = ""

	if data_file.file_exists(data_file_name):
		data_file.open(data_file_name, File.READ)

		var data_parsed = JSON.parse(data_file.get_as_text())
		if data_parsed.error == OK:
			turret_type = data_parsed.result.get("type", "")
		else:
			print("Error while parsing data file: ", data_file_name + " " + data_parsed.error_string)

		data_file.close()
	else:
		print("No such file: " + data_file_name)

	match turret_type:
		"energy_weapon":
			scene.set_script(EnergyWeaponTurret)

	return .post_import(scene)


const EnergyWeaponTurret = preload("EnergyWeaponTurret.gd")
