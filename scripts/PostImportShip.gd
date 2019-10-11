tool
extends "PostImportActor.gd"


func post_import(scene):
	var models_directory_regex = RegEx.new()
	models_directory_regex.compile("res://models/(?<directory>.+)")

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

	# Add script to weapon hardpoints groups
	for energy_hardpoints in scene.get_node("Energy Weapon Groups").get_children():
		energy_hardpoints.set_script(WeaponHardpoints)

	for missile_hardpoints in scene.get_node("Missile Weapon Groups").get_children():
		missile_hardpoints.set_script(WeaponHardpoints)

	# Some common physics settings
	scene.set_angular_damp(0.85)
	scene.set_linear_damp(0.85)

	# Add raycast for targeting
	var target_raycast = RayCast.new()
	scene.add_child(target_raycast)
	target_raycast.set_owner(scene)
	target_raycast.set_name("Target Raycast")
	target_raycast.set_cast_to(200 * Vector3.FORWARD)
	target_raycast.set_enabled(true)

	# This is used for loading the data file and other resources
	var source_folder = get_source_folder()
	var data_file = File.new()
	var data_file_name: String = source_folder + "/data.json"

	# Set defaults to be overridden by data file
	var ship_data: Dictionary = {
		"hull_hitpoints": 100.0,
		"max_speed": 32.0,
		"missile_capacity": 55,
		"shield_hitpoints": 100.0,
		"ship_class": "ship"
	}

	if data_file.file_exists(data_file_name):
		data_file.open(data_file_name, File.READ)

		var data_parsed = JSON.parse(data_file.get_as_text())
		if data_parsed.error == OK:
			var hull_hitpoints = data_parsed.result.get("hull_hitpoints")
			if hull_hitpoints != null and typeof(hull_hitpoints) == TYPE_REAL:
				ship_data["hull_hitpoints"] = hull_hitpoints

			var max_speed = data_parsed.result.get("max_speed")
			if max_speed != null and typeof(max_speed) == TYPE_REAL:
				ship_data["max_speed"] = max_speed

			var missile_capacity = data_parsed.result.get("missile_capacity")
			if missile_capacity != null and typeof(missile_capacity) == TYPE_REAL:
				ship_data["missile_capacity"] = missile_capacity

			var shield_hitpoints = data_parsed.result.get("shield_hitpoints")
			if shield_hitpoints != null and typeof(shield_hitpoints) == TYPE_REAL:
				ship_data["shield_hitpoints"] = shield_hitpoints

			var ship_class = data_parsed.result.get("ship_class")
			if ship_class != null and typeof(ship_class) == TYPE_STRING:
				ship_data["ship_class"] = ship_class
		else:
			print("Error while parsing data file: ", data_file_name + " " + data_parsed.error_string)
	else:
		print("No such file: " + data_file_name)

	scene.set_meta("hull_hitpoints", ship_data["hull_hitpoints"])
	scene.set_meta("max_speed", ship_data["max_speed"])
	scene.set_meta("missile_capacity", ship_data["missile_capacity"])
	scene.set_meta("shield_hitpoints", ship_data["shield_hitpoints"])
	scene.set_meta("ship_class", ship_data["ship_class"])

	scene.set_meta("source_file", get_source_file())
	scene.set_meta("source_folder", source_folder)

	return .post_import(scene)


const ShieldQuadrant = preload("ShieldQuadrant.gd")
const WeaponHardpoints = preload("WeaponHardpoints.gd")

const BLUE_EXHAUST_MATERIAL = preload("res://materials/blue_exhaust.tres")
const BLUE_SHIELD_MATERIAL = preload("res://materials/blue_shield.tres")
const EXHAUST_LIGHT_MATERIAL = preload("res://materials/exhaust_light.tres")
