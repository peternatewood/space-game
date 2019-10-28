extends Node

var current_scene
var thread: Thread = Thread.new()


func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)


func _load_scene(loader):
	while true:
		var error = loader.poll()

		if error == ERR_FILE_EOF:
			# Get the new scene
			var resource = loader.get_resource()
			call_deferred("_set_new_scene")

			return resource
		elif error == OK:
			_update_progress(loader)
		else:
			# TODO: handle error somehow
			print("Loader error! " + error)
			return


func _set_new_scene():
	var scene_resource = thread.wait_to_finish()

	if scene_resource == null:
		print("Scene failed to load!")
	else:
		# Unload the loading bar scene
		var root = get_tree().get_root()
		current_scene = root.get_child(root.get_child_count() - 1)
		current_scene.queue_free()

		# Set the new scene
		current_scene = scene_resource.instance()
		get_tree().get_root().add_child(current_scene)
		emit_signal("scene_loaded")


func _update_progress(loader):
	emit_signal("loading_progressed", 100 * float(loader.get_stage()) / loader.get_stage_count())


# PUBLIC


func change_scene(path: String):
	current_scene.queue_free()

	var scene_resource = load(path)
	current_scene = scene_resource.instance()
	get_tree().get_root().add_child(current_scene)


func load_scene(path: String):
	current_scene.queue_free()

	var tree = get_tree()
	tree.change_scene_to(LOADING_SCENE)
	if tree.paused:
		tree.set_pause(false)

	var loader = ResourceLoader.load_interactive(path)
	thread.start(self, "_load_scene", loader)


signal loading_progressed
signal scene_loaded

const LOADING_SCENE = preload("res://loading.tscn")
