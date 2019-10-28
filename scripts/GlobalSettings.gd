extends Object


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
