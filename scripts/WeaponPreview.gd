extends Control

onready var video_player = get_node("Video Player")


func _ready():
	video_player.connect("finished", video_player, "play")


# PUBLIC


func set_weapon(type: String, weapon_data):
	if not visible:
		show()

	video_player.set_stream(weapon_data.video)

	video_player.play()
