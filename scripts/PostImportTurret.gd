tool
extends EditorScenePostImport


func post_import(scene):
	# This is used for loading the data file and other resources
	var source_folder = get_source_folder()
	var data_file = File.new()
	var data_file_name: String = source_folder + "/data.json"

	# Set defaults to be overridden by data file
	var turret_type = ""
	var turret_data: Dictionary = {
		"hull_hitpoints": 10
	}

	if data_file.file_exists(data_file_name):
		data_file.open(data_file_name, File.READ)

		var data_parsed = JSON.parse(data_file.get_as_text())
		if data_parsed.error == OK:
			turret_type = data_parsed.result.get("type", "")

			var hull_hitpoints = data_parsed.result.get("hull_hitpoints")
			if hull_hitpoints != null and typeof(hull_hitpoints) == TYPE_REAL:
				turret_data["hull_hitpoints"] = hull_hitpoints
		else:
			print("Error while parsing data file: ", data_file_name + " " + data_parsed.error_string)

		data_file.close()
	else:
		print("No such file: " + data_file_name)

	scene.set_meta("hull_hitpoints", turret_data["hull_hitpoints"])

	match turret_type:
		"energy_weapon":
			scene.set_script(EnergyWeaponTurret)
			var barrels = scene.get_node("Barrels")
			# Add raycast to barrels for targeting
			var raycast_start: Vector3 = barrels.transform.origin
			var target_raycast = RayCast.new()
			barrels.add_child(target_raycast)
			target_raycast.set_owner(scene)
			target_raycast.transform.origin = raycast_start
			target_raycast.set_name("Target Raycast")
			target_raycast.set_cast_to(raycast_start + 200 * Vector3.FORWARD)
			target_raycast.set_enabled(true)

	var max_mesh_size: Vector3

	# Move static body collision shapes into root, and remove the static bodies
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

	return scene


const EnergyWeaponTurret = preload("EnergyWeaponTurret.gd")
