extends GameService
class_name WorldService

var world_tile_map: TileMap = null
var WIDTH = 10
var HEIGHT = 6
var a_star = AStar2D.new()
#var top_most_world_node: Node2D = null

func initialize_a_star() -> void:
	var i = 0
	for y in range(0, HEIGHT):
		for x in range(0,WIDTH):
			a_star.add_point(i, Vector2(x, y))
			i += 1
	var max_idx = i
	for j in range(0, max_idx):
		if not ((j+1) % WIDTH == 0): # not right edge
			a_star.connect_points(j, j+1)
		if j < (WIDTH * (HEIGHT-1)): # bottom row
			a_star.connect_points(j, j+WIDTH)
	for p in a_star.get_points():
		var connected_points = a_star.get_point_connections(p)
#		print_debug(str(p) + " is connected to " + str(connected_points))
	# Add walls
	var walls = [11, 24, 37, 47, 57]
	for w in walls:
		remove_point(w)
		
	return

func on_game_initialize() -> void:
	initialize_a_star()

func connect_snake_signals(snake_head: SnakeHead) -> void:
	snake_head.connect("completed_move", self, "_on_snake_completed_move")
	
	for p in a_star.get_points():
		var point_label = Label.new()
		point_label.text = str(p)
		var p_tile_position = a_star.get_point_position(p)
		var p_global_position = get_global_tile_position(p_tile_position)
		point_label.set_global_position(p_global_position)
		get_tree().root.add_child(point_label)
		

func remove_point(idx: int) -> void:
	var connected_points = a_star.get_point_connections(idx)
	for i in connected_points:
		a_star.disconnect_points(idx, i)
	a_star.remove_point(idx)

func get_global_tile_position(tile_position: Vector2) -> Vector2:
	if not world_tile_map:
		return Vector2.ZERO
		
	var local_tile_position = world_tile_map.map_to_world(tile_position)
	var cell_size = world_tile_map.cell_size
	var half_cell = cell_size / 2
	local_tile_position += half_cell
	return world_tile_map.to_global(local_tile_position)
	
	
func place_object_at_tile_position(node_to_place: Node2D, tile_position: Vector2) -> void:
	var new_global_position = get_global_tile_position(tile_position)
	node_to_place.global_position = new_global_position
	
	
func get_random_tile_position() -> Vector2:
	var random_index = Random.randi_range(0, a_star.get_points().size() - 1)
	var random_point = a_star.get_points()[random_index]
	var random_tile_position = a_star.get_point_position(random_point)
	
	return random_tile_position
	
	
func get_random_tile_position_as_global() -> Vector2:
	var tile_position = get_random_tile_position()
	return get_global_tile_position(tile_position)
	

func _on_snake_completed_move(prev_pos, cur_pos) -> void:
	add_snake_to_astar()

func add_snake_to_astar() -> void:
	for a in a_star.get_points():
		a_star.set_point_disabled(a, false)
	var snake_poses = Game.entity_service.get_snake_positions()
	for p in snake_poses:
		a_star.set_point_disabled(a_star.get_closest_point(p, true))
	if snake_poses.size() == 1:
		var from_spot = (-1 * Game.entity_service.get_snake_direction()) + snake_poses[0]
		a_star.set_point_disabled(a_star.get_closest_point(from_spot, true))
		
func calculate_route_between_points(from: Vector2, to: Vector2) -> PoolVector2Array:
	var from_id = a_star.get_closest_point(from)
	var to_id = a_star.get_closest_point(to)
	return a_star.get_point_path(from_id, to_id)


#func destroy_all_enemies() -> void:
#	var enemies = get_tree().get_nodes_in_group(Game.groups.roots.enemy)
#	for enemy in enemies:
#		var true_enemy = enemy `as EnemyRoot
#		if true_enemy:
#			true_enemy.call_deferred("die", false)
#
#
#func destroy_all_bullets() -> void:
#	var bullets = get_tree().get_nodes_in_group(Game.groups.roots.bullet)
#	for bullet in bullets:
#		var true_bullet = bullet as Bullet
#		if true_bullet:
#			true_bullet.call_deferred("die", false)
