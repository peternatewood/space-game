tool
extends "PostImportActor.gd"


func post_import(scene):
	# Change shield collision meshes to Area nodes
	for child in scene.get_children():
		if child.name.begins_with("Shield"):
			var shield_name = child.name
			child.set_name(shield_name + " Container")

			# Add the area node to the scene
			var area_node: Area = Area.new()
			scene.add_child(area_node)
			area_node.set_owner(scene)
			area_node.set_name(shield_name)

			# Get the collision shape and shield mesh
			var shield_static: StaticBody
			var shield_mesh: MeshInstance
			for node in child.get_children():
				if node is StaticBody:
					shield_static = node
				elif node is MeshInstance:
					shield_mesh = node.duplicate(Node.DUPLICATE_USE_INSTANCING)
					shield_mesh.transform = node.transform

					node.queue_free()

			#var collision_shape: CollisionShape = shield_static.get_node("shape").duplicate(Node.DUPLICATE_USE_INSTANCING)
			var collision_shape: CollisionShape
			for static_child in shield_static.get_children():
				if static_child is CollisionShape:
					collision_shape = static_child.duplicate(Node.DUPLICATE_USE_INSTANCING)
					collision_shape.transform = child.transform

					static_child.queue_free()
					break

			# Add the shield mesh (note: set_owner must be the Scene, not the node's parent)
			area_node.add_child(shield_mesh)
			shield_mesh.set_owner(scene)
			shield_mesh.set_name("mesh")
			shield_mesh.set_surface_material(0, BLUE_SHIELD_MATERIAL)
			shield_mesh.hide()

			# Add the collision shape
			area_node.add_child(collision_shape)
			collision_shape.set_name("shape")
			collision_shape.set_owner(scene)

			area_node.set_script(ShieldQuadrant)

			# Remove the static node and original shield mesh
			shield_static.queue_free()
			child.queue_free()

	var exhaust_mesh = scene.get_node("Exhaust")
	exhaust_mesh.set_surface_material(0, BLUE_EXHAUST_MATERIAL)
	exhaust_mesh.set_cast_shadows_setting(GeometryInstance.SHADOW_CASTING_SETTING_OFF)

	# Set exhaust billboard material
	var exhaust_points = scene.get_node("Exhaust Points")
	if exhaust_points != null:
		exhaust_points.set_surface_material(0, EXHAUST_LIGHT_MATERIAL)

	# Add engine effect sound at exhaust points center
	var engine_sound = AudioStreamPlayer3D.new()
	engine_sound.set_stream(ENGINE_LOOP)
	engine_sound.set_bus("Sound Effects")
	engine_sound.set_name("Engine Loop")
	scene.add_child(engine_sound)
	engine_sound.set_owner(scene)
	engine_sound.transform.origin = exhaust_points.transform.origin

	# Other sound effects
	var collision_sound = AudioStreamPlayer3D.new()
	collision_sound.set_stream(COLLISION_SOUND)
	collision_sound.set_bus("Sound Effects")
	collision_sound.set_name("Collision Sound Player")
	scene.add_child(collision_sound)
	collision_sound.set_owner(scene)

	var warp_boom = AudioStreamPlayer3D.new()
	warp_boom.set_unit_size(10)
	warp_boom.set_stream(WARP_BOOM)
	warp_boom.set_bus("Sound Effects")
	warp_boom.set_name("Warp Boom Player")
	scene.add_child(warp_boom)
	warp_boom.set_owner(scene)

	var warp_ramp_up = AudioStreamPlayer3D.new()
	warp_ramp_up.set_unit_size(10)
	warp_ramp_up.set_stream(WARP_RAMP_UP)
	warp_ramp_up.set_bus("Sound Effects")
	warp_ramp_up.set_name("Warp Ramp Up Player")
	scene.add_child(warp_ramp_up)
	warp_ramp_up.set_owner(scene)

	# Add script to weapon hardpoints groups
	if scene.has_node("Energy Weapon Groups"):
		for energy_hardpoints in scene.get_node("Energy Weapon Groups").get_children():
			energy_hardpoints.set_script(WeaponHardpoints)

	if scene.has_node("Missile Weapon Groups"):
		for missile_hardpoints in scene.get_node("Missile Weapon Groups").get_children():
			missile_hardpoints.set_script(WeaponHardpoints)

	# Not all capital ships will have all types of turret
	var has_beam_weapons = scene.has_node("Beam Weapon Turrets")
	scene.set_meta("has_beam_weapon_turrets", has_beam_weapons)
	var has_energy_weapons = scene.has_node("Energy Weapon Turrets")
	scene.set_meta("has_energy_weapon_turrets", has_energy_weapons)
	var has_missile_weapons = scene.has_node("Missile Weapon Turrets")
	scene.set_meta("has_missile_weapon_turrets", has_missile_weapons)

	# Replace turret placeholders with turret instances
	if has_beam_weapons:
		pass

	if has_energy_weapons:
		var turrets_container = scene.get_node("Energy Weapon Turrets")
		for turret_placeholder in turrets_container.get_children():
			var turret_xform: Transform = turret_placeholder.transform
			turret_placeholder.free()

			var turret = ENERGY_WEAPON_TURRET.instance()
			turret.transform = turret_xform
			scene.add_collision_exception_with(turret)
			turrets_container.add_child(turret)
			turret.set_owner(scene)

	if has_missile_weapons:
		pass

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

	# Prep Debris bodies
	if scene.has_node("Debris"):
		var debris_container = scene.get_node("Debris")
		for node in debris_container.get_children():
			# Just like importing actors, replace the static bodies with their collision shapes
			for child in node.get_children():
				if child is StaticBody:
					for static_child in child.get_children():
						if static_child is CollisionShape:
							var collision_shape = static_child.duplicate(Node.DUPLICATE_USE_INSTANCING)
							collision_shape.transform = child.transform
							node.add_child(collision_shape)
							collision_shape.set_owner(scene)
							# Also disable the shape since this is just for debris
							collision_shape.set_disabled(true)
							collision_shape.set_name("Collision Shape")

					node.remove_child(child)
				elif child is MeshInstance:
					child.set_name("Mesh")

			node.hide()

	# This is used for loading the data file and other resources
	var source_folder = get_source_folder()
	var data_file = File.new()
	var data_file_name: String = source_folder + "/data.json"

	# Set defaults to be overridden by data file
	var max_speed: float = 7.0
	var ship_data: Dictionary = {
		"is_capital_ship": false,
		"hull_hitpoints": 100.0,
		"missile_capacity": 55.0,
		"shield_hitpoints": 100.0,
		"ship_class": "ship",
		"turn_speed": 25
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

		data_file.close()
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
const COLLISION_SOUND = preload("res://sounds/collision.wav")
const ENERGY_WEAPON_TURRET = preload("res://models/turrets/energy_weapon_turret/model.dae")
const ENGINE_LOOP = preload("res://sounds/engine_loop.wav")
const EXHAUST_LIGHT_MATERIAL = preload("res://materials/exhaust_light.tres")
const WARP_BOOM = preload("res://sounds/warp_boom.wav")
const WARP_RAMP_UP = preload("res://sounds/warp_ramp_up.wav")
