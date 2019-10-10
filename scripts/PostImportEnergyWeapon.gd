tool
extends "res://scripts/PostImportActor.gd"


func post_import(scene):
	for node in scene.get_children():
		if node is MeshInstance:
			node.mesh.surface_get_material(0).flags_unshaded = true
			node.mesh.surface_get_material(0).flags_do_not_receive_shadows = true
			node.mesh.surface_get_material(0).flags_disable_ambient_light = true

	scene.set_mass(0.2)
	scene.set_script(EnergyBolt)

	return .post_import(scene)


const EnergyBolt = preload("EnergyBolt.gd")
