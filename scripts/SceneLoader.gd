extends Node

var current_scene
var loader
var wait_frames: int


func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)


func _process(delta):
	if loader == null:
		set_process(false)
		return

	if wait_frames > 0:
		wait_frames -= 1
		return

	var time = OS.get_ticks_msec()
	while OS.get_ticks_msec() < time + TIME_MAX:
		var error = loader.poll()

		if error == ERR_FILE_EOF:
			# Unload the loading bar scene
			var root = get_tree().get_root()
			current_scene = root.get_child(root.get_child_count() - 1)
			current_scene.queue_free()

			# Set the new scene
			var resource = loader.get_resource()
			loader = null
			_set_new_scene(resource)

			emit_signal("scene_loaded")
			break
		elif error == OK:
			_update_progress()
		else:
			# TODO: handle error somehow
			loader = null
			break


func _set_new_scene(scene_resource):
	current_scene = scene_resource.instance()
	get_tree().get_root().add_child(current_scene)


func _update_progress():
	emit_signal("loading_progressed", loader.get_stage())


# PUBLIC


func get_stage_count():
	if loader == null:
		return 1

	return loader.get_stage_count()


func change_scene(path):
	loader = ResourceLoader.load_interactive(path)
	if loader == null:
		# TODO: handle error somehow
		print("Loader is null!")
		return
	set_process(true)
	current_scene.queue_free()

	var tree = get_tree()
	#tree.change_scene("res://loading.tscn")
	tree.change_scene_to(LOADING_SCENE)
	if tree.paused:
		tree.set_pause(false)

	wait_frames = 1


signal loading_progressed
signal scene_loaded

const LOADING_SCENE = preload("res://loading.tscn")
const TIME_MAX: int = 10
