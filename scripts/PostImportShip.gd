tool
extends "PostImportActor.gd"


func post_import(scene):
	for child in scene.get_children():
		# Hide shield meshes by default
		if child.name.begins_with("Shield") and not child.name.ends_with("-convcolonly"):
			child.hide()

	var exhaust_mesh = scene.get_node("Exhaust")
	exhaust_mesh.set_surface_material(0, BLUE_EXHAUST_MATERIAL)
	exhaust_mesh.set_cast_shadows_setting(GeometryInstance.SHADOW_CASTING_SETTING_OFF)

	# Some common physics settings
	scene.set_gravity_scale(0)
	scene.set_angular_damp(0.85)
	scene.set_linear_damp(0.85)

	return .post_import(scene)


const BLUE_EXHAUST_MATERIAL = preload("res://materials/blue_exhaust.tres")
