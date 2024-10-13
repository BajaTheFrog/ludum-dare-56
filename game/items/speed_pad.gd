extends Node2D
class_name SpeedPad

func _ready():
	add_to_group(Game.groups.types.environment)
	$hotbox.add_to_group(Game.groups.hotboxes.speed_pad)


func _on_rotation_timer_timeout():
	rotation_degrees += 90
	rotation_degrees = fmod(rotation_degrees, 360.0)
	$arrows.rotation_degrees = -90
	var tween = create_tween()
	tween.tween_property($arrows, "rotation_degrees", 0, 0.3)
	
