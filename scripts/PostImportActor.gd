tool
extends EditorScenePostImport


func post_import(scene):
	var max_mesh_size: Vector3

	for child in scene.get_children():
		if child is StaticBody:
			for static_body_child in child.get_children():
				if static_body_child is CollisionShape:
					# Copy collision shape to scene root
					var collision_shape = static_body_child.duplicate(Node.DUPLICATE_USE_INSTANCING)
					collision_shape.transform = child.transform
					scene.add_child(collision_shape)
					collision_shape.set_owner(scene)

			# Remove unused StaticBody
			scene.remove_child(child)

		elif child is MeshInstance:
			for vertex in child.mesh.get_faces():
				var adjusted_vertex = vertex - child.transform.origin
				if adjusted_vertex.x > max_mesh_size.x:
					max_mesh_size.x = vertex.x
				if adjusted_vertex.y > max_mesh_size.y:
					max_mesh_size.y = vertex.y
				if adjusted_vertex.z > max_mesh_size.z:
					max_mesh_size.z = vertex.z

	var cube_mesh = CubeMesh.new()
	cube_mesh.set_size(2 * max_mesh_size)
	var bounding_box_extents = [
		max_mesh_size,
		Vector3(-max_mesh_size.x, max_mesh_size.y, max_mesh_size.z),
		Vector3(-max_mesh_size.x,-max_mesh_size.y, max_mesh_size.z),
		Vector3(-max_mesh_size.x, max_mesh_size.y,-max_mesh_size.z),
		Vector3(-max_mesh_size.x,-max_mesh_size.y,-max_mesh_size.z),
		Vector3( max_mesh_size.x,-max_mesh_size.y, max_mesh_size.z),
		Vector3( max_mesh_size.x, max_mesh_size.y,-max_mesh_size.z),
		Vector3( max_mesh_size.x,-max_mesh_size.y,-max_mesh_size.z)
	]
	scene.set_meta("bounding_box_extents", bounding_box_extents)
	scene.set_meta("cam_distance", max_mesh_size.length())

	# Skip this step if we already got hull_hitpoints, e.g. in PostImportShip.gd
	if not scene.has_meta("hull_hitpoints"):
		# This is used for loading the data file and other resources
		var source_folder = get_source_folder()
		var data_file = File.new()
		var data_file_name: String = source_folder + "/data.json"

		var actor_data: Dictionary = {
			"hull_hitpoints": 10
		}

		if data_file.file_exists(data_file_name):
			data_file.open(data_file_name, File.READ)

			var data_parsed = JSON.parse(data_file.get_as_text())
			if data_parsed.error == OK:
				var hull_hitpoints = data_parsed.result.get("hull_hitpoints")
				if hull_hitpoints != null and typeof(hull_hitpoints) == TYPE_REAL:
					actor_data["hull_hitpoints"] = hull_hitpoints

			data_file.close()

		scene.set_meta("hull_hitpoints", actor_data["hull_hitpoints"])

	# Collision sound
	var collision_sound = AudioStreamPlayer3D.new()
	collision_sound.set_stream(COLLISION_SOUND)
	collision_sound.set_name("Collision Sound Player")
	scene.add_child(collision_sound)
	collision_sound.set_owner(scene)

	scene.set_contact_monitor(true)
	scene.set_max_contacts_reported(4)

	return scene


const COLLISION_SOUND = preload("res://sounds/collision.wav")
