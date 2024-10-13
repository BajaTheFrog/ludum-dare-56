extends SnakeSegment
class_name SnakeHead

const MAX_HEALTH = 100

signal completed_body_move()

export (PackedScene) var segment_scene
export (float) var min_speed = 2 # tiles per second
export (float) var max_speed = 4 # tiles per second

onready var segments_parent: Node2D = $segments_parent
onready var current_direction = Vector2.RIGHT
onready var next_direction = Vector2.ZERO
onready var target_tile_position = Vector2.ZERO
onready var health_bar: ProgressBar = $health_bar

puppetsync var hit_points = MAX_HEALTH
var should_move = true
var target_player: Player = null
puppetsync var bloodlust = false


func _ready():
	place_at_tile_position(tile_position)
	connect("completed_move", self, "_on_completed_move")
	add_to_group(Game.groups.roots.snake)
	Game.world_service.connect_snake_signals(self)
	Game.events.game_round.connect("new_target_placed", self, "_on_new_target_placed")


func _process(delta):
	if should_move and is_network_master():
		if target_tile_position == tile_position:
			_target_captured()
		move()
	
	if bloodlust:
		$head_sprite.self_modulate = Color.red
	else:
		$head_sprite.self_modulate = Color.green
	
	_draw_line()
	health_bar.value = get_hit_point_percentage()
		
		
func _input(event):
	var input_vector = Vector2.ZERO
	
	if event.is_action_pressed("standard_move_up"):
		input_vector = Vector2.UP
	elif event.is_action_pressed("standard_move_right"):
		input_vector = Vector2.RIGHT
	elif event.is_action_pressed("standard_move_down"):
		input_vector = Vector2.DOWN
	elif event.is_action_pressed("standard_move_left"):
		input_vector = Vector2.LEFT
	else:
		return
		
	var is_opposite_direction = input_vector + current_direction == Vector2.ZERO
	if not is_opposite_direction:
		next_direction = input_vector
		

func get_speed() -> float:
	var calculated_speed = max_speed - (0.3 * segments_parent.get_child_count())
	return 	clamp(calculated_speed, min_speed, max_speed)


func get_hit_points() -> int: 
	return hit_points
	
	
func get_hit_point_percentage() -> float:
	return float(hit_points) / float(MAX_HEALTH)


func trigger_take_damage(amount: int) -> void:
	var head_amount = amount * 3
	emit_signal("take_damage", head_amount)
#	rpc("take_damage", head_amount)
	take_damage(head_amount)
	
	
func _on_segment_take_damage(amount: int) -> void:
#	rpc("take_damage", head_amount)
	take_damage(amount)
	
	
puppetsync func take_damage(amount: int) -> void:
	if is_network_master():
		rset("hit_points", hit_points-amount)
	
		if hit_points <= 0:
			Game.events.snake.emit_signal("snake_killed")

		
func move():
	should_move = false
	next_direction = _get_a_star_next_direction()
	var next_tile_position = tile_position + next_direction
	rpc("move_to_tile_position", next_tile_position, get_speed())
	move_segments()
	current_direction = next_direction
	Game.events.snake.emit_signal("completed_body_move")
	
	
func _draw_line():
	var global_positions = [Vector2.ZERO]
	var segments = segments_parent.get_children()
	for segment_child in segments:
		global_positions.append(segment_child.global_position - self.global_position)
		
	var snake_line = $line_2d as Line2D
	snake_line.clear_points()
	for point in global_positions:
		snake_line.add_point(point)
		
	
func rotate_to(radians: float):
	$head_sprite.rotation = radians
	$casts.rotation = radians
	
	
func move_segments():
	var next_segment_position = tile_position
	var previous_segment_position
	
	var segment_tile_positions = []
	var segments = segments_parent.get_children()
	for segment_child in segments:
		segment_tile_positions.append(next_segment_position)
		var snake_segment = segment_child as SnakeSegment
		if not snake_segment:
			continue
			
		previous_segment_position = snake_segment.tile_position
		snake_segment.move_to_tile_position(next_segment_position, get_speed())
		next_segment_position = previous_segment_position
		
	if is_network_master():
		rpc("sync_segments", segment_tile_positions)
	
		
puppet func sync_segments(positions_array: Array) -> void:
	# given an array of positions, set, add (and maybe delete) any segments 
	var segments = segments_parent.get_children()
	if segments.size() > positions_array.size():
		for segment in segments:
			segment.queue_free()
	for index in positions_array.size():
		var tile_position = positions_array[index]
		
		if index >= segments.size():
			_add_new_segment(tile_position)
		elif index < segments.size():
			var segment = segments[index] as SnakeSegment
			segment.move_to_tile_position(tile_position, get_speed())


func reset():
	hit_points = MAX_HEALTH
	for seg in segments_parent.get_children():
		seg.queue_free()
	tile_position = Vector2.ZERO
	previous_tile_position = Vector2.ZERO
	puppet_tile_position = Vector2.ZERO
	current_direction = Vector2.RIGHT
	next_direction = Vector2.ZERO
	bloodlust = false
	target_player = null
	place_at_tile_position(tile_position)
	if self.tween != null:
		self.tween.kill()
	should_move = true


func _on_completed_move(old_tile_position: Vector2, new_tile_position: Vector2) -> void:
	should_move = true
	
func _get_backup_direction():
	var route = Game.world_service.find_valid_target(tile_position)
	if route.empty():
		Game.events.snake.emit_signal("snake_doomed")
		# this shouldn't matter
		return current_direction
	route.remove(0)
	return route[0] - tile_position


func _on_new_target_placed(p_target_tile_position: Vector2) -> void:
	target_tile_position = p_target_tile_position


func _on_clear_target_player():
	target_player = null
	rset("bloodlust", false)
	print("Snake chilling out")


func _get_a_star_next_direction():
	var next_target = target_tile_position
	if target_player != null and is_instance_valid(target_player):
		next_target = Game.world_service.get_tile_position_from_global(target_player.position)
	else:
		for player in Game.world_service.players.get_children():
			if is_instance_valid(player) and $casts/vision_cone.overlaps_body(player):
				target_player = player
				rset("bloodlust", true)
				print("Snake targeting player " + player.get_name())
				next_target = Game.world_service.get_tile_position_from_global(player.position)
				Wait.on(self, 5.0).connect("timeout", self, "_on_clear_target_player")

	var route_to_target = Game.world_service.calculate_route_between_points(tile_position, next_target)
	if route_to_target.empty():
		return _get_backup_direction()
	if route_to_target[0] == tile_position:
		route_to_target.remove(0)
	if route_to_target.empty():
		return _get_backup_direction()
	if route_to_target[0] - tile_position == -1 * current_direction:
		var asd = Game.world_service.check_tile_disabled(route_to_target[0])
		return _get_backup_direction()
	var dir = route_to_target[0] - tile_position
	return dir

func _get_next_direction(allow_random_direction: bool = false) -> Vector2:
	# only try to change 50% of the time
	if allow_random_direction and Random.roll_chance(50):
		return _get_random_next_direction()
	
	if target_tile_position.y < tile_position.y:
		return Vector2.UP
	elif target_tile_position.y > tile_position.y:
		return Vector2.DOWN
	elif target_tile_position.x < tile_position.x:
		return Vector2.LEFT
	elif target_tile_position.x > tile_position.x:
		return Vector2.RIGHT
	
	return next_direction
	
	
func _get_random_next_direction() -> Vector2:		
	var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	directions.shuffle()
	var random_direction = directions[0]
	if random_direction + current_direction == Vector2.ZERO:
		return next_direction
	
	return random_direction
	

func _get_random_tile_position() -> Vector2:
	var random_x = Random.randi_range(0, 10)
	var random_y = Random.randi_range(0, 5)
	
	return Vector2(random_x, random_y)
	
	
func _target_captured() -> void:
	var spawned_tile_position = previous_tile_position
	var segment_children = segments_parent.get_children()
	
	if not segment_children.empty():
		var last_child = segment_children.back()
		var last_segment = last_child as SnakeSegment
		if last_segment:
			spawned_tile_position = last_segment.previous_tile_position
		
	rpc("_add_new_segment", spawned_tile_position)
	Game.events.snake.emit_signal("target_captured")


puppetsync func _add_new_segment(segment_tile_position: Vector2) -> void:
	var snake_segment_node = segment_scene.instance()
	segments_parent.add_child(snake_segment_node)
	snake_segment_node.place_at_tile_position(segment_tile_position)
	var snake_segment = snake_segment_node as SnakeSegment
	if snake_segment:
		snake_segment.connect("take_damage", self, "_on_segment_take_damage")


func _on_SNAKE_body_entered(body):
	Game.events.snake.emit_signal("caught_player", body)
