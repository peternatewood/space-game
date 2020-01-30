extends Control

onready var priority_spinbox = get_node("Priority SpinBox")
onready var target_options = get_node("Target Options")
onready var type_options = get_node("Type Options")
onready var waypoint_options = get_node("Waypoint Options")


func _ready():
	type_options.connect("item_selected", self, "_on_type_item_selected")


func _on_type_item_selected(item_index: int):
	match item_index:
		NPCShip.ORDER_TYPE.PATROL:
			target_options.hide()
			waypoint_options.show()
		NPCShip.ORDER_TYPE.ATTACK, NPCShip.ORDER_TYPE.DEFEND, NPCShip.ORDER_TYPE.IGNORE:
			target_options.show()
			waypoint_options.hide()
		_:
			target_options.hide()
			waypoint_options.hide()


# PUBLIC


func add_target(ship):
	target_options.add_item(ship.name, target_options.get_item_count())


func add_waypoint_group(group_name: String):
	waypoint_options.add_item(group_name, waypoint_options.get_item_count())


func get_order():
	var target_name = null
	var target_option_index: int = target_options.get_selected_id()

	if target_option_index != 0:
		target_name = target_options.get_item_text(target_option_index)

	return {
		"priority": priority_spinbox.value,
		"target": target_name,
		"type": type_options.get_selected_id()
	}


func remove_target(ship_name: String):
	for index in range(target_options.get_item_count()):
		if target_options.get_item_text(index) == ship_name:
			target_options.remove_item(index)
			break


func rename_target(old_name: String, new_name: String):
	for index in range(target_options.get_item_count()):
		if target_options.get_item_text(index) == old_name:
			target_options.set_item_text(index, new_name)
			break


func set_order(new_order: Dictionary):
	priority_spinbox.set_value(new_order.priority)
	type_options.select(new_order.type)
	_on_type_item_selected(new_order.type)

	target_options.select(0)
	if new_order.target:
		match new_order.type:
			NPCShip.ORDER_TYPE.PATROL:
				for index in range(waypoint_options.get_item_count()):
					if waypoint_options.get_item_text(index) == new_order.target:
						waypoint_options.select(index)
						break
			NPCShip.ORDER_TYPE.ATTACK, NPCShip.ORDER_TYPE.DEFEND, NPCShip.ORDER_TYPE.IGNORE:
				for index in range(target_options.get_item_count()):
					if target_options.get_item_text(index) == new_order.target:
						target_options.select(index)
						break
			_:
				target_options.select(0)


func set_targets(ships: Array):
	# Skip the first item since it's "none"
	var old_ship_count: int = target_options.get_item_count() - 1
	var new_ship_count: int = ships.size()

	for index in range(max(new_ship_count, old_ship_count)):
		if index >= old_ship_count:
			add_target(ships[index])
		elif index >= new_ship_count:
			# Add one since the first item is "none"
			target_options.remove_item(index + 1)
		else:
			# Add one since the first item is "none"
			target_options.set_item_text(index + 1, ships[index].name)


func set_waypoint_groups(waypoint_groups: Array):
	# Skip the first item since it's "none"
	var old_group_count: int = waypoint_options.get_item_count() - 1
	var new_group_count: int = waypoint_groups.size()

	for index in range(max(new_group_count, old_group_count)):
		if index >= old_group_count:
			add_waypoint_group(waypoint_groups[index])
		elif index >= new_group_count:
			# Add one since the first item is "none"
			waypoint_options.remove_item(index + 1)
		else:
			# Add one since the first item is "none"
			waypoint_options.set_item_text(index + 1, waypoint_groups[index].name)


func toggle_depart_order(toggle_on: bool):
	type_options.set_item_disabled(NPCShip.ORDER_TYPE.DEPART, not toggle_on)
	type_options.set_item_disabled(NPCShip.ORDER_TYPE.ARRIVE, toggle_on)


const NPCShip = preload("res://scripts/NPCShip.gd")
