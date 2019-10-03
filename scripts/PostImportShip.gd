tool
extends "PostImportActor.gd"


func post_import(scene):
	# Change shield collision meshes to Area nodes
	for child in scene.get_children():
		if child.name.begins_with("Shield") and child is MeshInstance:
			var shield_name = child.name
			child.set_name(shield_name + " Mesh")

			# Add the area node to the scene
			var area_node: Area = Area.new()
			scene.add_child(area_node)
			area_node.set_owner(scene)
			area_node.set_name(shield_name)

			# Get the collision shape and shield mesh
			var shield_static
			for node in scene.get_children():
				if node.name.begins_with(shield_name) and node is StaticBody:
					shield_static = node
					break
			var collision_shape: CollisionShape = shield_static.get_node("shape").duplicate(Node.DUPLICATE_USE_INSTANCING)
			collision_shape.transform = child.transform
			var shield_mesh: MeshInstance = child.duplicate(Node.DUPLICATE_USE_INSTANCING)

			# Add the shield mesh (note: set_owner must be the Scene, not the node's parent)
			area_node.add_child(shield_mesh)
			shield_mesh.set_owner(scene)
			shield_mesh.set_name("mesh")
			shield_mesh.set_surface_material(0, BLUE_SHIELD_MATERIAL)
			shield_mesh.hide()

			# Add the collision shape
			area_node.add_child(collision_shape)
			collision_shape.set_owner(scene)

			area_node.set_script(ShieldQuadrant)

			# Remove the static node and original shield mesh
			scene.remove_child(shield_static)
			scene.remove_child(child)

	var exhaust_mesh = scene.get_node("Exhaust")
	exhaust_mesh.set_surface_material(0, BLUE_EXHAUST_MATERIAL)
	exhaust_mesh.set_cast_shadows_setting(GeometryInstance.SHADOW_CASTING_SETTING_OFF)

	# Set exhaust billboard material
	var exhaust_points = scene.get_node("Exhaust Points")
	if exhaust_points != null:
		exhaust_points.set_surface_material(0, EXHAUST_LIGHT_MATERIAL)

	# Some common physics settings
	scene.set_angular_damp(0.85)
	scene.set_linear_damp(0.85)

	# This is used for loading the data file and other resources
	scene.set_meta("source_file", get_source_file())
	scene.set_meta("directory", get_source_folder())

	return .post_import(scene)


const ShieldQuadrant = preload("ShieldQuadrant.gd")

const BLUE_EXHAUST_MATERIAL = preload("res://materials/blue_exhaust.tres")
const BLUE_SHIELD_MATERIAL = preload("res://materials/blue_shield.tres")
const EXHAUST_LIGHT_MATERIAL = preload("res://materials/exhaust_light.tres")
