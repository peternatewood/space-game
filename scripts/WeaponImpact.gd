extends Spatial

onready var particles = get_node("Particles")


func _ready():
	particles.set_emitting(true)

	var free_timer = Timer.new()
	free_timer.set_one_shot(true)
	free_timer.set_autostart(true)
	free_timer.set_wait_time(particles.lifetime)
	free_timer.connect("timeout", self, "queue_free")

