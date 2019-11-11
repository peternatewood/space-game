extends Spatial

onready var arrow_x = get_node("Arrow X")
onready var arrow_y = get_node("Arrow Y")
onready var arrow_z = get_node("Arrow Z")


func hide():
	arrow_x.set_monitoring(false)
	arrow_x.set_monitorable(false)
	arrow_y.set_monitoring(false)
	arrow_y.set_monitorable(false)
	arrow_z.set_monitoring(false)
	arrow_z.set_monitorable(false)

	.hide()


func show():
	arrow_x.set_monitoring(true)
	arrow_x.set_monitorable(true)
	arrow_y.set_monitoring(true)
	arrow_y.set_monitorable(true)
	arrow_z.set_monitoring(true)
	arrow_z.set_monitorable(true)

	.show()
