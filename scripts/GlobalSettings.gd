extends Node

enum { MASTER, SOUND_EFFECTS, MUSIC, UI_SOUNDS, AUDIO_BUS_COUNT }
enum Colorblindness { FULL, PROTANOPIA, DEUTERANOPIA, TRITANOPIA, CUSTOM }
# Protanopia: no red photoreceptors
# Dueteranopia: similar to protanopia, without dimming effect
# Tritanopia: no blue photoreceptors (very rare)

# TODO: change to using .cfg format and manipulating ProjectSettings directly

var keybinds: Dictionary = {}
# Default settings
var settings: Dictionary = {}


func _ready():
	# Populate keybinds object from InputMap
	for action in InputMap.get_actions():
		keybinds[action] = Keybind.action_to_simplified_events(action)

	_load_default_settings()
	_load_keybinds_from_file()
	_load_settings_from_file()


func _load_default_settings():
	var settings_file = ConfigFile.new()
	var file_error = settings_file.load(DEFAULT_SETTINGS_PATH)

	if file_error == OK:
		for section in settings_file.get_sections():
			for key in settings_file.get_section_keys(section):
				settings[key] = Setting.new(section, settings_file.get_value(section, key))
	else:
		print("Default settings file load error: ", file_error)


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
	var file_error: int

	if settings_file.file_exists(SETTINGS_PATH):
		settings_file = ConfigFile.new()
		file_error = settings_file.load(SETTINGS_PATH)

		if file_error == OK:
			for section in settings_file.get_sections():
				for key in settings_file.get_section_keys(section):
					settings[key] = Setting.new(section, settings_file.get_value(section, key))
		else:
			print("User settings file read error: ", file_error)

	# Always save settings, in case the file is missing some defaults
	_save_all_settings_to_file()

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


func _save_all_settings_to_file():
	var settings_file = ConfigFile.new()

	for key in settings.keys():
		settings_file.set_value(settings[key]._section, key, settings[key]._value)

	settings_file.save(SETTINGS_PATH)


func _save_setting_to_file(key: String):
	if settings.has(key):
		var settings_file = File.new()
		# Just in case the user settings file is missing
		if not settings_file.file_exists(SETTINGS_PATH):
			_save_all_settings_to_file()

		settings_file = ConfigFile.new()
		settings_file.load(SETTINGS_PATH)

		settings_file.set_value(settings[key]._section, key, settings[key]._value)

		settings_file.save(SETTINGS_PATH)
	else:
		print("Invalid setting name: ", key)


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


func get_colorblindness():
	return settings.colorblindness.get_value()


func get_custom_ui_color(ui_index: int, faded: bool = false):
	if faded:
		var color = settings.custom_ui_colors.get_value()[ui_index]
		color.a = 0.5

		return color

	return settings.custom_ui_colors.get_value()[ui_index]


func get_dyslexia():
	return settings.dyslexia.get_value()


func get_fov():
	return settings.fov.get_value()


func get_fullscreen():
	return settings.fullscreen.get_value()


func get_hud_custom_color(path: String):
	var palette_colors = get_hud_palette()
	return palette_colors.get(path, palette_colors.default)


func get_hud_palette():
	var hud_palette_index: int = settings.hud_palette_index.get_value()

	if hud_palette_index == HUD_PALETTES.size():
		return settings.hud_palette_colors.get_value()

	return HUD_PALETTES[hud_palette_index]


func get_hud_palette_index():
	return settings.hud_palette_index.get_value()


func get_interface_color(alignment: int, faded: bool = false):
	var colorblindness_option = settings.colorblindness.get_value()

	if colorblindness_option == Colorblindness.CUSTOM:
		return get_custom_ui_color(alignment, faded)
	else:
		if faded:
			return INTERFACE_COLORS_FADED[colorblindness_option][alignment]

		return INTERFACE_COLORS[colorblindness_option][alignment]


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
			_save_setting_to_file("audio_master_percent")
		MUSIC:
			settings.audio_music_percent.set_value(percent)
			_save_setting_to_file("audio_music_percent")
		SOUND_EFFECTS:
			settings.audio_sound_effects_percent.set_value(percent)
			_save_setting_to_file("audio_sound_effects_percent")
		UI_SOUNDS:
			settings.audio_ui_sounds_percent.set_value(percent)
			_save_setting_to_file("audio_ui_sounds_percent")
		_:
			return

	AudioServer.set_bus_volume_db(bus_index, MathHelper.percent_to_db(percent))


func set_audio_mute(bus_index: int, toggle_on: bool):
	match bus_index:
		MASTER:
			settings.audio_master_mute.set_value(toggle_on)
			_save_setting_to_file("audio_master_mute")
		MUSIC:
			settings.audio_music_mute.set_value(toggle_on)
			_save_setting_to_file("audio_music_mute")
		SOUND_EFFECTS:
			settings.audio_sound_effects_mute.set_value(toggle_on)
			_save_setting_to_file("audio_sound_effects_mute")
		UI_SOUNDS:
			settings.audio_ui_sounds_mute.set_value(toggle_on)
			_save_setting_to_file("audio_ui_sounds_mute")
		_:
			return

	AudioServer.set_bus_mute(bus_index, toggle_on)


func set_borderless_window(toggle_on: bool):
	settings.borderless.set_value(toggle_on)
	OS.set_borderless_window(settings.borderless._value)

	_save_setting_to_file("borderless")


func set_colorblindness(option_index: int):
	settings.colorblindness.set_value(option_index)
	emit_signal("ui_colors_changed")

	_save_setting_to_file("colorblindness")


func set_custom_ui_color(type: int, new_color: Color):
	var ui_colors = settings.custom_ui_colors._value
	ui_colors[type] = new_color
	settings.custom_ui_colors.set_value(ui_colors)
	emit_signal("ui_colors_changed")

	_save_setting_to_file("ui_colors")


func set_dyslexia(toggle_on: bool):
	settings.dyslexia.set_value(toggle_on)
	emit_signal("dyslexia_toggled", settings.dyslexia._value)

	_save_setting_to_file("dyslexia")


func set_fov(value: int):
	settings.fov.set_value(value)
	emit_signal("fov_changed", settings.fov._value)

	_save_setting_to_file("fov")


func set_fullscreen(toggle_on: bool):
	settings.fullscreen.set_value(toggle_on)
	_update_fullscreen()

	_save_setting_to_file("fullscreen")


func set_hdr(toggle_on: bool):
	settings.hdr.set_value(toggle_on)
	get_viewport().set_hdr(settings.hdr._value)

	_save_setting_to_file("hdr")


func set_hud_custom_color(node_path: String, new_color: Color):
	var palette_colors = settings.hud_palette_colors.get_value()
	palette_colors[node_path] = new_color
	settings.hud_palette_colors.set_value(palette_colors)
	emit_signal("hud_palette_color_changed", node_path)

	_save_setting_to_file("hud_palette_colors")


func set_hud_palette(index: int):
	settings.hud_palette_index.set_value(index)
	emit_signal("hud_palette_changed")

	_save_setting_to_file("hud_palette_index")


func set_msaa(option: int):
	settings.msaa.set_value(option)
	get_viewport().set_msaa(settings.msaa._value)

	_save_setting_to_file("msaa")


func set_resolution(new_resolution: Vector2):
	settings.resolution.set_value(new_resolution)
	_update_resolution()

	_save_setting_to_file("resolution")

	return settings.resolution._value


func set_shadows_dir_atlas_size(value: int):
	settings.shadows_dir.set_value(value)

	_save_setting_to_file("shadows_dir")


func set_shadows_point_atlas_size(value: int):
	settings.shadows_point.set_value(value)

	_save_setting_to_file("shadows_point")


func set_units(new_units: int):
	settings.units.set_value(new_units)
	emit_signal("units_changed", settings.units._value)

	_save_setting_to_file("units")


func set_vsync(toggle_on: bool):
	settings.vsync.set_value(toggle_on)
	OS.set_use_vsync(settings.vsync._value)

	_save_setting_to_file("vsyncs")


signal dyslexia_toggled
signal fov_changed
signal hud_palette_changed
signal hud_palette_color_changed
signal ui_colors_changed
signal units_changed

const Keybind = preload("Keybind.gd")
const MathHelper = preload("MathHelper.gd")

const DEFAULT_SETTINGS_PATH = "res://settings.cfg"
const DISTANCE_UNITS: Array = [
	"m",
	"ft"
]
const HUD_PALETTES: Array = [
	{ "default": Color("#80c0ff") }, # All light blue
	{ "default": Color("#80d040") }, # All green
	{ "default": Color("#ffc080") }  # All amber
	# TODO: add more custom options
]
const INTERFACE_COLORS: Array = [
	[ Color(1.00, 1.00, 0.15, 1.0), Color(0.35, 1.00, 0.15, 1.0), Color(1.00, 0.35, 0.15, 1.0) ],
	[ Color(1.00, 1.00, 0.75, 1.0), Color(0.00, 0.50, 1.00, 1.0), Color(1.00, 0.50, 0.00, 1.0) ],
	[ Color(1.00, 1.00, 0.85, 1.0), Color(0.00, 0.65, 1.00, 1.0), Color(1.00, 0.65, 0.00, 1.0) ],
	[ Color(1.00, 1.00, 0.90, 1.0), Color(0.00, 0.50, 1.00, 1.0), Color(1.00, 0.25, 0.25, 1.0) ]
]
const INTERFACE_COLORS_FADED: Array = [
	[ Color(1.00, 1.00, 0.00, 0.75), Color(0.25, 1.00, 0.25, 0.75), Color(1.00, 0.25, 0.25, 0.75) ],
	[ Color(1.00, 1.00, 0.75, 0.75), Color(0.00, 0.50, 1.00, 0.75), Color(1.00, 0.50, 0.00, 0.75) ],
	[ Color(1.00, 1.00, 0.85, 0.75), Color(0.00, 0.65, 1.00, 0.75), Color(1.00, 0.65, 0.00, 0.75) ],
	[ Color(1.00, 1.00, 0.90, 0.75), Color(0.00, 0.50, 1.00, 0.75), Color(1.00, 0.25, 0.25, 0.75) ]
]
const INCONSOLATA_THEME = preload("res://themes/default_inconsolata.tres")
const INCONSOLATA_INTERFACE_THEME = preload("res://themes/interface_blue.tres")
const KEYBINDS_PATH: String = "user://keybinds.json"
const OPEN_DYSLEXIC_INTERFACE_THEME = preload("res://themes/interface_blue_dyslexia.tres")
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
const SETTINGS_PATH: String = "user://settings.cfg"
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
	var _section: String
	var _type: int
	var _value


	func _init(section: String, value):
		_section = section

		if value != null:
			_type = typeof(value)
			set_value(value)
		else:
			_type = TYPE_NIL


	# PUBLIC


	func get_value():
		return _value


	func set_value(value):
		if typeof(value) == _type:
			_value = value

		elif _type == TYPE_INT:
			_value = int(value)

		elif typeof(value) == TYPE_STRING:
			_value = str2var(value)

		else:
			print("Invalid type for this setting: " + str(typeof(value)))
			return null

		return _value
