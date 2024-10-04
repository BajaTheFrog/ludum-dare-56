extends Flasher
class_name FixedTimeFlasher

export (float) var duration_of_flashes

var duration_timer

func _ready():
	duration_timer = Timer.new()
	duration_timer.connect("timeout", self, "_on_duration_timeout")
	add_child(duration_timer)
	duration_timer.wait_time = duration_of_flashes
	duration_timer.one_shot = false
	if auto_start:
		start()


func _on_duration_timeout():
	stop()


func start():
	if duration_timer:
		duration_timer.wait_time = duration_of_flashes
		duration_timer.start()
		.start()
