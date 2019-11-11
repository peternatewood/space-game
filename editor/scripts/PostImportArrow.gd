tool
extends EditorScenePostImport


func post_import(scene):
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
			child.mesh.surface_get_material(0).set_flag(SpatialMaterial.FLAG_FIXED_SIZE, true)

	return scene
