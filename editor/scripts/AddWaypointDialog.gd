extends AcceptDialog

onready var waypoint_group_options = get_node("Add Waypoint Columns/Waypoint Group Options")


func populate_group_options(group_names: Array):
	var current_group_count: int = waypoint_group_options.get_item_count()
	var new_group_count: int = group_names.size()

	for index in range(max(current_group_count, new_group_count)):
		if index >= current_group_count:
			# Add new item
			waypoint_group_options.add_item(group_names[index], index)
		else:
			# Update current item text
			waypoint_group_options.set_item_text(index, group_names[index])
		if index >= new_group_count:
			# Remove old item
			waypoint_group_options.remove_option(index)
