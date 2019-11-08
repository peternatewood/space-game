extends Node

enum { MASTER, MUSIC, SOUND_EFFECTS, UI_SOUNDS, AUDIO_BUS_COUNT }

var keybinds: Dictionary = {}
# Default settings
var settings: Dictionary = {
	"aniso_filtering": Setting.new("aniso_filtering", 0),
	"audio_master_percent": Setting.new("audio_master_percent", 100),
	"audio_master_mute": Setting.new("audio_master_mute", false),
	"audio_music_percent": Setting.new("audio_music_percent", 100),
	"audio_music_mute": Setting.new("audio_music_mute", false),
	"audio_sound_effects_percent": Setting.new("audio_sound_effects_percent", 100),
	"audio_sound_effects_mute": Setting.new("audio_sound_effects_mute", false),
	"audio_ui_sounds_percent": Setting.new("audio_ui_sounds_percent", 100),
	"audio_ui_sounds_mute": Setting.new("audio_ui_sounds_mute", false),
	"borderless": Setting.new("borderless", false),
	"dyslexia": Setting.new("dyslexia", false),
	"fov": Setting.new("fov", 70),
	"fullscreen": Setting.new("fullscreen", false),
	"hdr": Setting.new("hdr", false),
	"msaa": Setting.new("msaa", 0),
	"reflections": Setting.new("reflections", 2048),
	"resolution": Setting.new("resolution", Vector2(1280, 720)),
	"shadows_dir": Setting.new("shadows_dir", 4096),
	"shadows_point": Setting.new("shadows_point", 4096),
	"subsurf_scatter": Setting.new("subsurf_scatter", 0),
	"units": Setting.new("units", MathHelper.Units.METRIC),
	"vsync": Setting.new("vsync", true)
}


func _ready():
	# Populate keybinds object from InputMap
	for action in InputMap.get_actions():
		keybinds[action] = Keybind.action_to_simplified_events(action)

	_load_keybinds_from_file()
	_load_settings_from_file()


func _load_keybinds_from_file():
	var keybinds_file = File.new()
	if keybinds_file.file_exists(KEYBINDS_PATH):
		var file_error = keybinds_file.open(KEYBINDS_PATH, File.READ)
		if file_error == OK:
			var parse_result = JSON.parse(keybinds_file.get_as_text())
			if parse_result.error == OK:
				for action in parse_result.result.keys():
					if keybinds.has(action):
						keybinds[action] = parse_result.result[action]
			else:
				print("Error parsing keybinds file: " + parse_result.error_string)
		else:
			print("File read error: " + str(file_error))

		keybinds_file.close()
	else:
		print("File not found")

	_save_keybinds_to_file()


func _load_settings_from_file():
	var settings_file = File.new()
	if settings_file.file_exists(SETTINGS_PATH):
		var file_error = settings_file.open(SETTINGS_PATH, File.READ)
		if file_error == OK:
			var parse_result = JSON.parse(settings_file.get_as_text())
			if parse_result.error == OK:
				for key in parse_result.result.keys():
					if settings.has(key):
						settings[key].set_value(parse_result.result[key])
			else:
				print("Error parsing settings file: " + parse_result.error_string)
		else:
			print("File read error: " + str(file_error))

		settings_file.close()
	else:
		print("File not found")

	# Always save settings, in case the file is missing some defaults
	_save_settings_to_file()

	# Actually update settings from file settings
	for bus_index in range(AUDIO_BUS_COUNT):
		var percent: float
		var toggle_on: bool

		match bus_index:
			MASTER:
				percent = settings.audio_master_percent.get_value()
				toggle_on = settings.audio_master_mute.get_value()
			MUSIC:
				percent = settings.audio_music_percent.get_value()
				toggle_on = settings.audio_music_mute.get_value()
			SOUND_EFFECTS:
				percent = settings.audio_sound_effects_percent.get_value()
				toggle_on = settings.audio_sound_effects_mute.get_value()
			UI_SOUNDS:
				percent = settings.audio_ui_sounds_percent.get_value()
				toggle_on = settings.audio_ui_sounds_mute.get_value()
			_:
				continue

		AudioServer.set_bus_volume_db(bus_index, MathHelper.percent_to_db(percent))
		AudioServer.set_bus_mute(bus_index, toggle_on)

	_update_fullscreen()
	_update_resolution()


func _on_keybind_changed(action):
	var simplified_events = Keybind.action_to_simplified_events(action)
	keybinds[action] = simplified_events

	_save_keybinds_to_file()


func _save_keybinds_to_file():
	var keybinds_file = File.new()
	keybinds_file.open(KEYBINDS_PATH, File.WRITE)
	keybinds_file.store_string(JSON.print(keybinds))
	keybinds_file.close()


func _save_settings_to_file():
	var settings_file = File.new()
	settings_file.open(SETTINGS_PATH, File.WRITE)

	var string_settings: Dictionary = {}
	for key in settings.keys():
		match settings[key]._type:
			TYPE_BOOL, TYPE_INT, TYPE_REAL, TYPE_STRING:
				string_settings[key] = settings[key]._value
			_:
				string_settings[key] = settings[key]._value_string

	settings_file.store_string(JSON.print(string_settings))
	settings_file.close()


func _update_fullscreen():
	OS.set_window_fullscreen(settings.fullscreen._value)

	if settings.fullscreen._value:
		get_viewport().set_size(settings.resolution._value)


func _update_resolution():
	if settings.fullscreen._value:
		get_viewport().set_size(settings.resolution._value)
	else:
		OS.set_window_size(settings.resolution._value)


# PUBLIC


func get_audio_percent(bus_index: int):
	match bus_index:
		MASTER:
			return settings.audio_master_percent.get_value()
		MUSIC:
			return settings.audio_music_percent.get_value()
		SOUND_EFFECTS:
			return settings.audio_sound_effects_percent.get_value()
		UI_SOUNDS:
			return settings.audio_ui_sounds_percent.get_value()


func get_audio_mute(bus_index: int):
	match bus_index:
		MASTER:
			return settings.audio_master_mute.get_value()
		MUSIC:
			return settings.audio_music_mute.get_value()
		SOUND_EFFECTS:
			return settings.audio_sound_effects_mute.get_value()
		UI_SOUNDS:
			return settings.audio_ui_sounds_mute.get_value()


func get_borderless_window():
	return settings.borderless_window.get_value()


func get_dyslexia():
	return settings.dyslexia.get_value()


func get_fov():
	return settings.fov.get_value()


func get_fullscreen():
	return settings.fullscreen.get_value()


func get_hdr():
	return settings.hdr.get_value()


func get_msaa():
	return settings.msaa.get_value()


func get_resolution():
	return settings.resolution.get_value()


func get_shadows_dir_atlas_size():
	return settings.shadows_dir.get_value()


func get_shadows_point_atlas_size():
	return settings.shadows_point.get_value()


func get_units():
	return settings.units.get_value()


func get_vsync():
	return settings.vsync.get_value()


func set_audio_percent(bus_index: int, percent: float):
	match bus_index:
		MASTER:
			settings.audio_master_percent.set_value(percent)
		MUSIC:
			settings.audio_music_percent.set_value(percent)
		SOUND_EFFECTS:
			settings.audio_sound_effects_percent.set_value(percent)
		UI_SOUNDS:
			settings.audio_ui_sounds_percent.set_value(percent)
		_:
			return

	AudioServer.set_bus_volume_db(bus_index, MathHelper.percent_to_db(percent))
	_save_settings_to_file()


func set_audio_mute(bus_index: int, toggle_on: bool):
	match bus_index:
		MASTER:
			settings.audio_master_mute.set_value(toggle_on)
		MUSIC:
			settings.audio_music_mute.set_value(toggle_on)
		SOUND_EFFECTS:
			settings.audio_sound_effects_mute.set_value(toggle_on)
		UI_SOUNDS:
			settings.audio_ui_sounds_mute.set_value(toggle_on)
		_:
			return

	AudioServer.set_bus_mute(bus_index, toggle_on)
	_save_settings_to_file()


func set_borderless_window(toggle_on: bool):
	settings.borderless.set_value(toggle_on)
	OS.set_borderless_window(settings.borderless._value)

	_save_settings_to_file()


func set_dyslexia(toggle_on: bool):
	settings.dyslexia.set_value(toggle_on)
	emit_signal("dyslexia_toggled", settings.dyslexia._value)

	_save_settings_to_file()


func set_fov(value: int):
	settings.fov.set_value(value)
	emit_signal("fov_changed", settings.fov._value)

	_save_settings_to_file()


func set_fullscreen(toggle_on: bool):
	settings.fullscreen.set_value(toggle_on)
	_update_fullscreen()

	_save_settings_to_file()


func set_hdr(toggle_on: bool):
	settings.hdr.set_value(toggle_on)
	get_viewport().set_hdr(settings.hdr._value)

	_save_settings_to_file()


func set_msaa(option: int):
	settings.msaa.set_value(option)
	get_viewport().set_msaa(settings.msaa._value)

	_save_settings_to_file()


func set_resolution(new_resolution: Vector2):
	settings.resolution.set_value(new_resolution)
	_update_resolution()

	_save_settings_to_file()

	return settings.resolution._value


func set_shadows_dir_atlas_size(value: int):
	settings.shadows_dir.set_value(value)

	_save_settings_to_file()


func set_shadows_point_atlas_size(value: int):
	settings.shadows_point.set_value(value)

	_save_settings_to_file()


func set_units(new_units: int):
	settings.units.set_value(new_units)
	emit_signal("units_changed", settings.units._value)

	_save_settings_to_file()


func set_vsync(toggle_on: bool):
	settings.vsync.set_value(toggle_on)
	OS.set_use_vsync(settings.vsync._value)

	_save_settings_to_file()


signal dyslexia_toggled
signal fov_changed
signal units_changed

const Keybind = preload("Keybind.gd")
const MathHelper = preload("MathHelper.gd")

const DISTANCE_UNITS: Array = [
	"m",
	"ft"
]
const INCONSOLATA_THEME = preload("res://themes/default_inconsolata.tres")
const KEYBINDS_PATH: String = "user://keybinds.json"
const OPEN_DYSLEXIC_THEME = preload("res://themes/default_dyslexic.tres")
const RESOLUTIONS: Array = [
	# 4:3
	Vector2(800, 600),
	Vector2(1024, 768),
	Vector2(1280, 960),
	Vector2(1400, 1050),
	Vector2(1600, 1200),
	# 8:5
	Vector2(1280, 800),
	Vector2(1440, 900),
	Vector2(1680, 1050),
	Vector2(1920, 1200),
	# 5:4
	Vector2(1280, 1024),
	# 9:16
	Vector2(720, 1280),
	# 16:9
	Vector2(1024, 600),
	Vector2(1280, 720),
	Vector2(1360, 768),
	Vector2(1366, 768),
	Vector2(1600, 900),
	Vector2(1920, 1080),
	Vector2(2560, 1440),
	# 16:10
	Vector2(1280, 800),
	Vector2(1920, 1200),
	Vector2(2560, 1600),
	Vector2(3840, 2400)
]
const SETTINGS_PATH: String = "user://settings.json"
# Low, Medium, High, Maximum
const SHADOW_QUALITY: Array = [
	1024,
	2048,
	4096,
	8192
]
const SPEED_UNITS: Array = [
	"m/s",
	"knt"
]


# Used to maintain properties of a given setting
class Setting:
	var _name: String
	var _type: int
	var _value
	var _value_string: String


	func _init(name: String, value):
		_name = name

		if value != null:
			_type = typeof(value)
			set_value(value)
		else:
			_type = TYPE_NIL
			_value_string = "null"


	# PUBLIC


	func get_name():
		return _name


	func get_value():
		return _value


	func set_value(value):
		if value == null:
			_value_string = "null"
			return

		if typeof(value) == _type:
			_value = value
			_value_string = var2str(_value)

			return _value
		elif _type == TYPE_INT:
			_value = int(value)
			_value_string = var2str(_value)

			return _value
		elif typeof(value) == TYPE_STRING:
			_value = str2var(value)
			_value_string = value

			return _value
		else:
			print("Invalid type for " + _name + " setting: " + str(typeof(value)))

		return null
