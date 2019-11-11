extends Spatial

onready var arrow_x = get_node("Arrow X")
onready var arrow_y = get_node("Arrow Y")
onready var arrow_z = get_node("Arrow Z")


func toggle(toggle_on: bool):
	arrow_x.set_monitoring(toggle_on)
	arrow_x.set_monitorable(toggle_on)
	arrow_y.set_monitoring(toggle_on)
	arrow_y.set_monitorable(toggle_on)
	arrow_z.set_monitoring(toggle_on)
	arrow_z.set_monitorable(toggle_on)
