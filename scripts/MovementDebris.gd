extends Spatial

onready var mission_controller = get_node_or_null("/root/Mission Controller")

var debris_particles: Array = []


func _ready():
	if mission_controller != null:
		mission_controller.connect("mission_ready", self, "_on_mission_ready")

	set_process(false)


func _on_mission_ready():
	var debris_prefab = load("res://prefabs/movement_debris.tscn")
	for index in range(DEBRIS_COUNT):
		var debris_instance = debris_prefab.instance()
		add_child(debris_instance)
		var direction: Vector3 = Vector3(2 * randf() - 1, 2 * randf() - 1, 2 * randf() - 1)
		debris_instance.transform.origin = MAX_DISTANCE * direction
		debris_particles.append(debris_instance)

	set_process(true)


func _process(delta):
	var to_player: Vector3
	for debris in debris_particles:
		to_player = mission_controller.player.transform.origin - debris.transform.origin
		if to_player.length_squared() > MAX_DISTANCE_SQ:
			debris.transform.origin += 2 * MAX_DISTANCE * to_player.normalized()


const DEBRIS_COUNT: int = 32
const MAX_DISTANCE: float = 10.0
const MAX_DISTANCE_SQ: float = 100.0
