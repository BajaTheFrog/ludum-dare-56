extends Node2D
class_name SnakeSegment

signal completed_move(old_tile_position, new_tile_position)

onready var previous_tile_position = Vector2.ZERO
onready var tile_position = Vector2.ZERO
		
func move_to_tile_position(p_tile_position: Vector2, tween_speed: float) -> void:
	var old_tile_position = tile_position
	var next_global_position = Game.world_service.get_global_tile_position(p_tile_position)
	var tween = create_tween()
	tween.tween_property(self, "global_position", next_global_position, 1.0 / tween_speed)
	yield(tween, "finished")
	tile_position = p_tile_position
	previous_tile_position = old_tile_position
	emit_signal("completed_move", previous_tile_position, tile_position)


func place_at_tile_position(give_tile_position: Vector2) -> void:
	tile_position = give_tile_position
	var tile_global_position = Game.world_service.get_global_tile_position(tile_position)
	self.global_position = tile_global_position
