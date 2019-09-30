tool
extends "res://scripts/PostImportActor.gd"


func post_import(scene):
	scene.set_mass(0.2)
	scene.set_script(Missile)

	return .post_import(scene)


const Missile = preload("Missile.gd")
