tool
extends "res://scripts/PostImportCollision.gd"


func post_import(scene):
	# Change shield collision meshes to KinematicBody nodes
	var shields: Array = []

	for child in scene.get_children():
		if child.name.begins_with("Shield"):
			var shield_name = child.name
			child.set_name(shield_name + " Container")

			# Add the kinematic body node to the scene
			var shield_area: Area = Area.new()
			scene.add_child(shield_area)
			shield_area.set_owner(scene)
			shield_area.set_name(shield_name)

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

			var collision_shape: CollisionShape
			for static_child in shield_static.get_children():
				if static_child is CollisionShape:
					collision_shape = static_child.duplicate(Node.DUPLICATE_USE_INSTANCING)
					collision_shape.transform = child.transform

					static_child.queue_free()
					break

			# Add the shield mesh (note: set_owner must be the Scene, not the node's parent)
			shield_area.add_child(shield_mesh)
			shield_mesh.set_owner(scene)
			shield_mesh.set_name("mesh")
			shield_mesh.set_surface_material(0, BLUE_SHIELD_MATERIAL)
			shield_mesh.hide()

			# Add the collision shape
			shield_area.add_child(collision_shape)
			collision_shape.set_name("shape")
			collision_shape.set_owner(scene)

			shields.append(shield_area)
			shield_area.set_script(ShieldQuadrant)

			# Remove the static node and original shield mesh
			shield_static.queue_free()
			child.queue_free()

	var exhaust_mesh = scene.get_node("Exhaust")
	exhaust_mesh.set_surface_material(0, BLUE_EXHAUST_MATERIAL)
	exhaust_mesh.set_cast_shadows_setting(GeometryInstance.SHADOW_CASTING_SETTING_OFF)

	# Set exhaust billboard material
	var exhaust_points = scene.get_node("Exhaust Points")
	if exhaust_points != null:
		for quad in exhaust_points.get_children():
			quad.set_surface_material(0, EXHAUST_LIGHT_MATERIAL)

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
		var turrets_container = scene.get_node("Beam Weapon Turrets")
		for turret in turrets_container.get_children():
			var turret_body: KinematicBody = KinematicBody.new()
			turrets_container.add_child(turret_body)
			turret_body.set_owner(scene)
			turret_body.transform = turret.transform

			var hardpoint: Spatial

			# Move static body collision shapes into root, and remove the static bodies
			for child in turret.get_children():
				if child is StaticBody:
					for static_body_child in child.get_children():
						if static_body_child is CollisionShape:
							# Copy collision shape to turret root
							var collision_shape = static_body_child.duplicate(Node.DUPLICATE_USE_INSTANCING)
							turret_body.add_child(collision_shape)
							collision_shape.transform = child.transform
							collision_shape.set_owner(scene)

				elif child.name.begins_with("Hardpoint"):
					hardpoint = child.duplicate(Node.DUPLICATE_USE_INSTANCING)
					turret_body.add_child(hardpoint)
					hardpoint.transform = child.transform
					hardpoint.set_owner(scene)
					hardpoint.set_name("Hardpoint")

				elif child is MeshInstance:
					var mesh_instance = child.duplicate(Node.DUPLICATE_USE_INSTANCING)
					turret_body.add_child(mesh_instance)
					mesh_instance.transform = child.transform
					mesh_instance.set_owner(scene)

					if child.name.begins_with("Turret Base"):
						mesh_instance.set_name("Turret Base")

			# Remove turret spatial
			turret.free()

			turret_body.set_meta("hull_hitpoints", 100.0)
			turret_body.set_script(BeamWeaponTurret)

	if has_energy_weapons:
		var turrets_container = scene.get_node("Energy Weapon Turrets")
		for turret in turrets_container.get_children():
			var turret_body: KinematicBody = KinematicBody.new()
			turrets_container.add_child(turret_body)
			turret_body.set_owner(scene)
			turret_body.transform = turret.transform

			var barrels: MeshInstance

			# Move static body collision shapes into root, and remove the static bodies
			for child in turret.get_children():
				if child is StaticBody:
					for static_body_child in child.get_children():
						if static_body_child is CollisionShape:
							# Copy collision shape to turret root
							var collision_shape = static_body_child.duplicate(Node.DUPLICATE_USE_INSTANCING)
							turret_body.add_child(collision_shape)
							collision_shape.transform = child.transform
							collision_shape.set_owner(scene)

				elif child is MeshInstance:
					var mesh_instance = child.duplicate(Node.DUPLICATE_USE_INSTANCING)
					turret_body.add_child(mesh_instance)
					mesh_instance.transform = child.transform
					mesh_instance.set_owner(scene)

					if child.name.begins_with("Turret Base"):
						mesh_instance.set_name("Turret Base")
					elif child.name.begins_with("Barrels"):
						barrels = mesh_instance
						barrels.set_name("Barrels")

					# The hardpoints don't get duplicated, so we have to dupe them manually
					for mesh_child in child.get_children():
						var hardpoint = mesh_child.duplicate(Node.DUPLICATE_USE_INSTANCING)
						mesh_instance.add_child(hardpoint)
						hardpoint.set_owner(scene)

			# Remove turret spatial
			turret.free()

			# Add raycast to barrels for targeting
			var raycast_start: Vector3 = Vector3.ZERO
			var target_raycast = RayCast.new()
			barrels.add_child(target_raycast)
			target_raycast.set_owner(scene)
			target_raycast.transform.origin = raycast_start
			target_raycast.set_name("Target Raycast")
			target_raycast.set_cast_to(raycast_start + 200 * Vector3.FORWARD)
			target_raycast.set_enabled(true)

			turret_body.set_meta("hull_hitpoints", 100.0)
			turret_body.set_script(EnergyWeaponTurret)

	if has_missile_weapons:
		var turrets_container = scene.get_node("Missile Weapon Turrets")
		for turret in turrets_container.get_children():
			var turret_body: KinematicBody = KinematicBody.new()
			turrets_container.add_child(turret_body)
			turret_body.set_owner(scene)
			turret_body.transform = turret.transform

			var missile_rack: MeshInstance

			# Move static body collision shapes into root, and remove the static bodies
			for child in turret.get_children():
				if child is StaticBody:
					for static_body_child in child.get_children():
						if static_body_child is CollisionShape:
							# Copy collision shape to turret root
							var collision_shape = static_body_child.duplicate(Node.DUPLICATE_USE_INSTANCING)
							turret_body.add_child(collision_shape)
							collision_shape.transform = child.transform
							collision_shape.set_owner(scene)

				elif child is MeshInstance:
					var mesh_instance = child.duplicate(Node.DUPLICATE_USE_INSTANCING)
					turret_body.add_child(mesh_instance)
					mesh_instance.transform = child.transform
					mesh_instance.set_owner(scene)

					if child.name.begins_with("Turret Base"):
						mesh_instance.set_name("Turret Base")
					elif child.name.begins_with("Missile Rack"):
						missile_rack = mesh_instance
						missile_rack.set_name("Missile Rack")

						# The hardpoints don't get duplicated, so we have to dupe them manually
						for mesh_child in child.get_children():
							var hardpoint = mesh_child.duplicate(Node.DUPLICATE_USE_INSTANCING)
							mesh_instance.add_child(hardpoint)
							hardpoint.set_owner(scene)

			# Remove turret spatial
			turret.free()

			# Add raycast to missile_rack for targeting
			var raycast_start: Vector3 = Vector3.ZERO
			var target_raycast = RayCast.new()
			missile_rack.add_child(target_raycast)
			target_raycast.set_owner(scene)
			target_raycast.transform.origin = raycast_start
			target_raycast.set_name("Target Raycast")
			target_raycast.set_cast_to(raycast_start + 200 * Vector3.FORWARD)
			target_raycast.set_enabled(true)

			turret_body.set_meta("hull_hitpoints", 100.0)
			turret_body.set_script(MissileWeaponTurret)

	# Add raycast for targeting
	var raycast_start: Vector3
	var cockpit_view = scene.get_node_or_null("Cockpit View")
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

					child.free()
				elif child is MeshInstance:
					child.set_name("Mesh")

			node.hide()

	var fuselage_extents: PoolVector3Array
	var fuselage_extents_mesh = scene.get_node_or_null("Fuselage Extents")
	if fuselage_extents_mesh == null:
		print("Missing Fuselage Extents mesh!")
	else:
		fuselage_extents = fuselage_extents_mesh.mesh.get_faces()
		fuselage_extents_mesh.free()

	scene.set_meta("fuselage_extents", fuselage_extents)

	# This is used for loading the data file and other resources
	var source_folder = get_source_folder()
	var ships_config: ConfigFile = ConfigFile.new()
	ships_config.load("res://configs/ships.cfg")

	# TODO: validate these properties more strictly to allow for foolproof user models
	# Set defaults to be overridden by config file
	var is_capital_ship: bool = false
	var max_hull_hitpoints: float = 75.0
	var max_speed: float = 7.0
	var missile_capacity: float = 55.0
	var shield_hitpoints: float = 100.0

	# All the properties that can be imported with just a type check
	var ship_data: Dictionary = {
		"hull_hitpoints": 100.0,
		"mass": 10.0, # Use mass to push stuff?
		"ship_class": "ship",
		"subsystem_hitpoints": {
			"Communications": 40.0,
			"Engines": 80.0,
			"Navigation": 40.0,
			"Sensors": 60.0,
			"Weapons": 85.0
		},
		"turn_speed": Vector3(TAU / 2.0, TAU / 3.0, TAU / 2.5) # Radians per second
	}

	# Load ship data from config file
	for section in ships_config.get_sections():
		if source_folder.ends_with(section):
			for key in ship_data.keys():
				if ships_config.has_section_key(section, key):
					var property = ships_config.get_value(section, key)

					if typeof(ship_data[key]) == typeof(property):
						ship_data[key] = property
					else:
						print("Invalid type, ", typeof(property), ", for ", key, " of type ", typeof(scene.get(key)))
				else:
					print("Missing ship property: ", key)

			var config_is_capital_ship = ships_config.get_value(section, "is_capital_ship")
			if typeof(config_is_capital_ship) == typeof(is_capital_ship):
				is_capital_ship = config_is_capital_ship

			if not is_capital_ship:
				var config_missile_capacity = ships_config.get_value(section, "missile_capacity")
				if typeof(config_missile_capacity) == typeof(missile_capacity):
					missile_capacity = config_missile_capacity

				var config_shield_hitpoints = ships_config.get_value(section, "shield_hitpoints")
				if typeof(config_shield_hitpoints) == typeof(shield_hitpoints):
					shield_hitpoints = config_shield_hitpoints

			var config_max_hull_hitpoints = ships_config.get_value(section, "hull_hitpoints")
			if typeof(config_max_hull_hitpoints) == typeof(max_hull_hitpoints):
				max_hull_hitpoints = config_max_hull_hitpoints

			var config_max_speed = ships_config.get_value(section, "max_speed")
			if typeof(config_max_speed) == typeof(max_speed):
				max_speed = config_max_speed / 10

			scene.set_meta("ship_class", section)
			break

	for key in ship_data.keys():
		scene.set_meta(key, ship_data[key])

	scene.set_meta("is_capital_ship", is_capital_ship)
	scene.set_meta("max_hull_hitpoints", max_hull_hitpoints)
	scene.set_meta("max_speed", max_speed)
	scene.set_meta("missile_capacity", missile_capacity)
	scene.set_meta("shield_hitpoints", shield_hitpoints)

	# Handle Subsystem collision shapes
	var subsystems_container = scene.get_node_or_null("Subsystems")
	if subsystems_container == null:
		print("Subsystems container missing!")
	else:
		var subsystem_name_regex: RegEx = RegEx.new()
		subsystem_name_regex.compile("Sub (\\w+)")

		for child in subsystems_container.get_children():
			var subsystem_name_match = subsystem_name_regex.search(child.name)
			if subsystem_name_match.strings.size() < 2:
				print("Invalid subsystem name: ", child.name)
			else:
				var subsystem_area: Area = Area.new()
				subsystems_container.add_child(subsystem_area)
				subsystem_area.set_owner(scene)

				subsystem_area.transform = child.transform
				subsystem_area.set_name(subsystem_name_match.strings[1])

				var collision_shape
				for static_child in child.get_children():
					if static_child is CollisionShape:
						collision_shape = static_child.duplicate(Node.DUPLICATE_USE_INSTANCING)
						break

				child.queue_free()

				subsystem_area.add_child(collision_shape)
				collision_shape.set_owner(scene)

				var explosion_instance = SUBSYSTEM_EXPLOSION.instance()
				subsystem_area.add_child(explosion_instance)
				explosion_instance.set_owner(scene)
				explosion_instance.set_name("Explosion")

				var subsystem_explosion_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
				subsystem_area.add_child(subsystem_explosion_player)
				subsystem_explosion_player.set_owner(scene)
				subsystem_explosion_player.set_stream(SUBSYSTEM_EXPLOSION_SOUND)
				subsystem_explosion_player.set_bus("Sound Effects")
				subsystem_explosion_player.set_name("Explosion Sound")

				subsystem_area.set_meta("hitpoints", ship_data.subsystem_hitpoints.get(subsystem_area.name, 50.0))

				subsystem_area.set_script(Subsystem)

	scene.set_meta("source_file", get_source_file())
	scene.set_meta("source_folder", source_folder)

	return .post_import(scene)


const BeamWeaponTurret = preload("BeamWeaponTurret.gd")
const EnergyWeaponTurret = preload("EnergyWeaponTurret.gd")
const MathHelper = preload("MathHelper.gd")
const MissileWeaponTurret = preload("MissileWeaponTurret.gd")
const ShieldQuadrant = preload("ShieldQuadrant.gd")
const Subsystem = preload("Subsystem.gd")
const WeaponHardpoints = preload("WeaponHardpoints.gd")

const BLUE_EXHAUST_MATERIAL = preload("res://materials/blue_exhaust.tres")
const BLUE_SHIELD_MATERIAL = preload("res://materials/blue_shield.tres")
const COLLISION_SOUND = preload("res://sounds/collision.wav")
const ENGINE_LOOP = preload("res://sounds/engine_loop.wav")
const EXHAUST_LIGHT_MATERIAL = preload("res://materials/exhaust_light.tres")
const SUBSYSTEM_EXPLOSION = preload("res://prefabs/subsystem_explosion.tscn")
const SUBSYSTEM_EXPLOSION_SOUND = preload("res://sounds/subsystem_explosion.wav")
const WARP_BOOM = preload("res://sounds/warp_boom.wav")
const WARP_RAMP_UP = preload("res://sounds/warp_ramp_up.wav")
