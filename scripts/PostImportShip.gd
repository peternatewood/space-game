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
	var raycast_start: Vector3
	var cockpit_view = scene.get_node("Cockpit View")
	if cockpit_view != null:
		raycast_start = cockpit_view.transform.origin

	var target_raycast = RayCast.new()
	scene.add_child(target_raycast)
	target_raycast.set_owner(scene)
	target_raycast.transform.origin = raycast_start
	target_raycast.set_name("Target Raycast")
	target_raycast.set_cast_to(raycast_start + 200 * Vector3.FORWARD)
	target_raycast.set_enabled(true)

	# This is used for loading the data file and other resources
	var source_folder = get_source_folder()
	var data_file = File.new()
	var data_file_name: String = source_folder + "/data.json"

	# Set defaults to be overridden by data file
	var max_speed: float = 7.0
	var ship_data: Dictionary = {
		"hull_hitpoints": 100.0,
		"missile_capacity": 55,
		"shield_hitpoints": 100.0,
		"ship_class": "ship"
	}

	if data_file.file_exists(data_file_name):
		data_file.open(data_file_name, File.READ)

		var data_parsed = JSON.parse(data_file.get_as_text())
		if data_parsed.error == OK:
			for key in ship_data.keys():
				var property = data_parsed.result.get(key)
				if property != null and typeof(property) == typeof(ship_data[key]):
					ship_data[key] = property

			var mass = data_parsed.result.get("mass")
			if mass != null and typeof(mass) == TYPE_REAL:
				scene.set_mass(mass)

			# Speed in data file is in m/s, so we have to divide by 10 to get actual value
			var parsed_max_speed = data_parsed.result.get("max_speed")
			if parsed_max_speed != null and typeof(parsed_max_speed) == TYPE_REAL:
				max_speed = parsed_max_speed / 10
		else:
			print("Error while parsing data file: ", data_file_name + " " + data_parsed.error_string)
	else:
		print("No such file: " + data_file_name)

	for key in ship_data.keys():
		scene.set_meta(key, ship_data[key])

	scene.set_meta("max_speed", max_speed)
	scene.set_meta("propulsion_force", MathHelper.get_propulsion_force_from_mass_and_speed(max_speed, scene.mass))
	scene.set_meta("source_file", get_source_file())
	scene.set_meta("source_folder", source_folder)

	return .post_import(scene)


const MathHelper = preload("MathHelper.gd")
const ShieldQuadrant = preload("ShieldQuadrant.gd")
const WeaponHardpoints = preload("WeaponHardpoints.gd")

const BLUE_EXHAUST_MATERIAL = preload("res://materials/blue_exhaust.tres")
const BLUE_SHIELD_MATERIAL = preload("res://materials/blue_shield.tres")
const EXHAUST_LIGHT_MATERIAL = preload("res://materials/exhaust_light.tres")
