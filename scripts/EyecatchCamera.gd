extends Camera

enum { TRACK, CHASE, COCKPIT, MODE_COUNT }

onready var mission_controller = get_tree().get_root().get_node_or_null("Mission Controller")

var mode = -1
var mode_timer: Timer
var target_ship


func _ready():
	set_process(false)
	mode = randi() % MODE_COUNT

	if mission_controller != null:
		mission_controller.connect("mission_ready", self, "_on_mission_ready")


func _on_mission_ready():
	mode_timer = get_node("Camera Timer")
	mode_timer.connect("timeout", self, "_on_timer_timeout")

	mode_timer.start()

	_on_timer_timeout()
	set_process(true)


func _on_target_exiting_tree():
	target_ship = null
	_on_timer_timeout()
	mode_timer.start()


func _on_timer_timeout():
	if target_ship != null:
		target_ship.disconnect("tree_exiting", self, "_on_target_exiting_tree")

		if mode == COCKPIT:
			target_ship.show()

	var ships = mission_controller.get_targets()
	target_ship = ships[randi() % ships.size()]
	target_ship.connect("tree_exiting", self, "_on_target_exiting_tree")

	if target_ship.is_capital_ship:
		mode = TRACK
	else:
		var new_mode = randi() % MODE_COUNT

		if new_mode == mode:
			new_mode = (mode + 1) % MODE_COUNT

		mode = new_mode

	match mode:
		TRACK:
			var cam_offset = target_ship.cam_distance * Vector3(randf(), randf(), randf())
			transform.origin = target_ship.transform.origin + cam_offset
		COCKPIT:
			target_ship.hide()


func _process(delta):
	match mode:
		TRACK:
			look_at(target_ship.transform.origin, Vector3.UP)
		CHASE:
			transform.origin = target_ship.chase_view.global_transform.origin
			look_at(transform.origin - target_ship.transform.basis.z, target_ship.transform.basis.y)
		COCKPIT:
			transform.origin = target_ship.transform.origin
			look_at(transform.origin - target_ship.transform.basis.z, target_ship.transform.basis.y)
