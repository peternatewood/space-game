extends Node

# Default settings here
var aniso_filtering = Setting.new("aniso_filtering", 0)
var borderless = Setting.new("borderless", false)
var fov = Setting.new("fov", 70)
var fullscreen = Setting.new("fullscreen", false)
var hdr = Setting.new("hdr", false)
var msaa = Setting.new("msaa", 0)
var reflections = Setting.new("reflections", 2048)
var resolution = Setting.new("resolution", Vector2(1024, 768))
var shadows_dir = Setting.new("shadows_dir", 4096)
var shadows_point = Setting.new("shadows_point", 4096)
var subsurf_scatter = Setting.new("subsurf_scatter", 0)
var vsync = Setting.new("vsync", true)


func set_borderless_window(toggle_on: bool):
	borderless.set_value(toggle_on)
	OS.set_borderless_window(borderless._value)


func set_fullscreen(toggle_on: bool):
	fullscreen.set_value(toggle_on)

	OS.set_window_fullscreen(fullscreen._value)

	if fullscreen._value:
		get_viewport().set_size(resolution._value)


func set_resolution(new_resolution: Vector2):
	resolution.set_value(new_resolution)

	if fullscreen._value:
		get_viewport().set_size(resolution._value)
	else:
		OS.set_window_size(resolution._value)

	return resolution._value


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
		else:
			print("Invalid type for " + _name + " setting")

		return null
