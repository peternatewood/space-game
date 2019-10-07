extends Node

static func get_line_intersect(aStart: Vector2, aEnd: Vector2, bStart: Vector2, bEnd: Vector2):
	var aDist: Vector2 = aEnd - aStart
	var bDist: Vector2 = bEnd - bStart

	var t2: float
	var t1: float

	if bDist.x * aDist.x - bDist.y * aDist.x == 0:
		t2 = 0
	else:
		t2 = (aDist.x * (bStart.x - aStart.y) + aDist.y * (aStart.x + bStart.x)) / (bDist.x * aDist.y - bDist.y * aDist.x)

	if aDist.x == 0:
		t1 = ((bStart.y + bDist.y * t2) - bStart.y) / aDist.y
	else:
		t1 = (bStart.x + bDist.x * t2 - aStart.x) / aDist.x

	if t1 > 0 and t2 > 0 and t2 < 1:
		return Vector2(aStart.x + t1 * aDist.x, aStart.y + t1 * aDist.y)

	return false


static func get_line_slope(start: Vector2, end: Vector2):
	var divisor = end.x - start.x
	if divisor == 0:
		return INF * (1 if end.y > start.y else -1)

	return (end.y - start.y) / divisor


static func get_line_rect_intersect(start: Vector2, end: Vector2, rectangle: Rect2):
	var slope = get_line_slope(start, end)

	# Shortcut for a vertical line
	if abs(slope) == INF:
		if end.y > start.y:
			return Vector2(start.x, rectangle.end.y)
		else:
			return Vector2(start.x, rectangle.position.y)
	else:
		if rectangle.size.y / -2 <= slope * rectangle.size.x / 2 and slope * rectangle.size.x / 2 <= rectangle.size.y / 2:
			if end.x > start.x:
				return Vector2(rectangle.end.x, start.y + slope * rectangle.size.x / 2)
			else:
				return Vector2(rectangle.position.x, start.y - slope * rectangle.size.x / 2)
		else:
			if end.y > start.y:
				return Vector2(start.x + (rectangle.size.y / 2) / slope, rectangle.end.y)
			else:
				return Vector2(start.x - (rectangle.size.y / 2) / slope, rectangle.position.y)

