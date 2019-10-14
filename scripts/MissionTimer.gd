extends Control

onready var minutes_label = get_node("Mission Timer Columns/Minutes")
onready var seconds_label = get_node("Mission Timer Columns/Seconds")

var seconds_countdown: float = 0.0
var minutes_countdown: float = 0.0
var time: float = 0.0 # In seconds


func _process(delta):
	if seconds_countdown <= 0:
		seconds_label.set_text(str((int(time) % 60)).pad_zeros(2))
		seconds_countdown += 1.0

	if minutes_countdown <= 0:
		minutes_label.set_text(str(round(time / 60)).pad_zeros(2))
		minutes_countdown += 60.0

	time += delta
	seconds_countdown -= delta
	minutes_countdown -= delta
