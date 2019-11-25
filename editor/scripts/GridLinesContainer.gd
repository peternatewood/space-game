extends Node2D

export (NodePath) var camera_path

var camera: Camera
var lines: Array = []


func _ready():
	camera = get_node(camera_path)

	var line_count: int = 30
	var line_interval: int = 10

	var line_length: int = line_count / 2

	for row in range(line_count + 1):
		var line: Line2D = Line2D.new()
		line.set_width(2 if (row % line_interval == 0) else 1)
		line.set_default_color(Color(0.5, 0.5, 0.5))
		line.add_point(Vector2())
		line.add_point(Vector2())
		add_child(line)

		lines.append({ "start": Vector3(-line_length + row, 0, -line_length), "end": Vector3(-line_length + row, 0, line_length), "line": line })

	for column in range(line_count + 1):
		var line: Line2D = Line2D.new()
		line.set_width(2 if (column % line_interval == 0) else 1)
		line.set_default_color(Color(0.5, 0.5, 0.5))
		line.add_point(Vector2())
		line.add_point(Vector2())
		add_child(line)

		lines.append({ "start": Vector3(-line_length, 0, -line_length + column), "end": Vector3(line_length, 0, -line_length + column), "line": line })


func _process(delta):
	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	var viewport_center: Vector2 = viewport_rect.size / 2

	for line in lines:
		var start_2d: Vector2 = camera.unproject_position(line.start)
		if camera.is_position_behind(line.start):
			# TODO: this is almost correct, but the lines are still distorted
			start_2d = viewport_center - (start_2d - viewport_center)

		if start_2d != line.line.get_point_position(0):
			var end_2d: Vector2 = camera.unproject_position(line.end)
			if camera.is_position_behind(line.end):
				end_2d = viewport_center - (end_2d - viewport_center)

			line.line.set_point_position(0, start_2d)
			line.line.set_point_position(1, end_2d)
