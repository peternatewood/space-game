extends Viewport

onready var camera = get_node("Camera Gimbal/Camera")
onready var camera_gimbal = get_node("Camera Gimbal")


func update_camera(other_cam):
	camera_gimbal.transform = other_cam.transform
	camera.transform = other_cam.camera.transform
