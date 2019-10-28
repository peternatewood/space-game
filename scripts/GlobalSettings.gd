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
		else:
			print("Invalid type for " + _name + " setting")
