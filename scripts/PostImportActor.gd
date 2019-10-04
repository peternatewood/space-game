tool
extends EditorScenePostImport


func post_import(scene):
	var max_mesh_size: Vector2
	var min_mesh_size: Vector2

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

		elif child is MeshInstance and not child.name.begins_with("Shield"):
			for vertex in child.mesh.get_faces():
				if vertex.x > max_mesh_size.x:
					max_mesh_size.x = vertex.x
				if vertex.y > max_mesh_size.y:
					max_mesh_size.y = vertex.y

				if vertex.x < min_mesh_size.x:
					min_mesh_size.x = vertex.x
				if vertex.y < min_mesh_size.y:
					min_mesh_size.y = vertex.y

	var mesh_size = abs(max(min_mesh_size.length(), max_mesh_size.length()))
	scene.set_meta("mesh_size", mesh_size)

	scene.set_contact_monitor(true)
	scene.set_max_contacts_reported(4)

	return scene
