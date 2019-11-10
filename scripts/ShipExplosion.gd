extends Spatial

onready var particles = get_node("Particles")


func _ready():
	var death_timer = Timer.new()
	death_timer.set_autostart(true)
	death_timer.set_one_shot(true)
	death_timer.set_wait_time(particles.lifetime)
	death_timer.connect("timeout", self, "queue_free")
	add_child(death_timer)
