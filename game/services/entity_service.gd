extends GameService
class_name EntityService


func get_player_root_node() -> Node2D:
	var group_name = Game.groups.roots.player
	var player_root_nodes = get_tree().get_nodes_in_group(group_name)
	if player_root_nodes.empty():
		return null
	else:
		return player_root_nodes[0]

func get_snake_root_node() -> SnakeHead:
	var group_name = Game.groups.roots.snake
	var snake_root_nodes = get_tree().get_nodes_in_group(group_name)
	if snake_root_nodes.empty():
		return null
	else:
		return snake_root_nodes[0] as SnakeHead

func get_snake_direction() -> Vector2:
	var snake: SnakeHead = get_snake_root_node()
	return snake.current_direction

func get_snake_positions() -> Array:
	var snake: SnakeHead = get_snake_root_node()
	var positions = []
	positions.append(snake.tile_position)
	var segment_children = snake.segments_parent.get_children()
	for c in segment_children:
		var snake_body = c as SnakeSegment
		positions.append(snake_body.tile_position)
	return positions
