extends Node

enum Units { METRIC, IMPERIAL }

# Default settings
var settings: Dictionary = {
	"aniso_filtering": Setting.new("aniso_filtering", 0),
	"borderless": Setting.new("borderless", false),
	"dyslexia": Setting.new("dyslexia", false),
	"fov": Setting.new("fov", 70),
	"fullscreen": Setting.new("fullscreen", false),
	"hdr": Setting.new("hdr", false),
	"msaa": Setting.new("msaa", 0),
	"reflections": Setting.new("reflections", 2048),
	"resolution": Setting.new("resolution", Vector2(1024, 768)),
	"shadows_dir": Setting.new("shadows_dir", 4096),
	"shadows_point": Setting.new("shadows_point", 4096),
	"subsurf_scatter": Setting.new("subsurf_scatter", 0),
	"units": Setting.new("units", Units.METRIC),
	"vsync": Setting.new("vsync", true)
}


func get_borderless_window():
	return settings.borderless_window.get_value()


func get_dyslexia():
	return settings.dyslexia.get_value()


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


func set_borderless_window(toggle_on: bool):
	settings.borderless.set_value(toggle_on)
	OS.set_borderless_window(settings.borderless._value)


func set_dyslexia(toggle_on: bool):
	settings.dyslexia.set_value(toggle_on)
	emit_signal("dyslexia_toggled", settings.dyslexia._value)


func set_fullscreen(toggle_on: bool):
	settings.fullscreen.set_value(toggle_on)

	OS.set_window_fullscreen(settings.fullscreen._value)

	if settings.fullscreen._value:
		get_viewport().set_size(settings.resolution._value)


func set_hdr(toggle_on: bool):
	settings.hdr.set_value(toggle_on)
	get_viewport().set_hdr(settings.hdr._value)


func set_msaa(option: int):
	settings.msaa.set_value(option)
	get_viewport().set_msaa(settings.msaa._value)


func set_resolution(new_resolution: Vector2):
	settings.resolution.set_value(new_resolution)

	if settings.fullscreen._value:
		get_viewport().set_size(settings.resolution._value)
	else:
		OS.set_window_size(settings.resolution._value)

	return settings.resolution._value


func set_shadows_dir_atlas_size(value: int):
	settings.shadows_dir.set_value(value)


func set_shadows_point_atlas_size(value: int):
	settings.shadows_point.set_value(value)


func set_units(new_units: int):
	settings.units.set_value(new_units)
	emit_signal("units_changed", settings.units._value)


func set_vsync(toggle_on: bool):
	settings.vsync.set_value(toggle_on)
	OS.set_use_vsync(settings.vsync._value)


signal dyslexia_toggled
signal units_changed

const DISTANCE_UNITS: Array = [
	"m",
	"ft"
]
const INCONSOLATA_THEME = preload("res://themes/default_inconsolata.tres")
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
		elif typeof(value) == TYPE_STRING:
			_value = str2var(value)
			_value_string = value
		else:
			print("Invalid type for " + _name + " setting")

		return null
