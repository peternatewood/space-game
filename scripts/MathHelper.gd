extends Object

enum Units { METRIC, IMPERIAL }


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


static func get_propulsion_force_from_mass_and_speed(mass: float, max_speed: float):
	return max_speed * mass * MASS_SPEED_FACTOR


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


static func get_force_from_mass_and_speed(mass: float, speed: float):
	return ((speed / 10) * mass) / (5.0 / 300.0)


static func percent_to_db(percent: float):
	return 20 * log(percent) / log(10) - 40


static func round_to_places(amount: float, places: int):
	if places < 1:
		return round(amount)

	var multiplier = pow(10, places)

	return round(multiplier * amount) / multiplier


static func units_to_distance(amount: float, units: int):
	match units:
		Units.METRIC:
			return 10 * amount
		Units.IMPERIAL:
			return 32.8084 * amount


static func units_to_speed(amount: float, units: int):
	match units:
		Units.METRIC:
			return 10 * amount
		Units.IMPERIAL:
			return 19.438445 * amount


# This one turned out to be too high?
#const MASS_SPEED_FACTOR: float = 0.031124095253675
const MASS_SPEED_FACTOR: float = 0.015562047626838

"""
TODO: figure out the curve for this conversion; for now we're just expecting 0.85 damping for all ships
Damping: 0.25 | Mass: 1.0 | Max Speed: 209.063675

Damping: 0.50 | Mass: 0.5 | Max Speed: 124.124451
Damping: 0.50 | Mass: 1.0 | Max Speed:  87.062263
Damping: 0.50 | Mass: 2.0 | Max Speed:  43.531090
Damping: 0.50 | Mass:10.0 | Max Speed:   8.706212

Damping: 0.85 | Mass: 0.5 | Max Speed:  64.258858
Damping: 0.85 | Mass: 1.0 | Max Speed:  32.129448
Damping: 0.85 | Mass: 2.0 | Max Speed:  16.064760
Damping: 0.85 | Mass:10.0 | Max Speed:   3.212944

Damping: 0.95 | Mass: 1.0 | Max Speed:  20.532631

max_speed = factor * 32.129448 / mass
factor = max_speed * mass / 32.129448
"""
