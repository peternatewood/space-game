extends RigidBody

var damage_hull: int = 15
var damage_shield: int = 10
var fire_delay: float = 0.3 # In seconds
var firing_force: float = 1.0
var firing_range: float = 10.0
var life: float = 5.0 # In seconds
var owner_ship
var speed: float = 80.0
var weapon_name: String = "weapon"


func _ready():
	if has_meta("firing_range"):
		firing_range = get_meta("firing_range")


func _process(delta):
	life -= delta
	if life <= 0:
		queue_free()


# PUBLIC


func destroy():
	queue_free()
