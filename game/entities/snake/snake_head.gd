extends SnakeSegment
class_name SnakeHead

export (PackedScene) var segment_scene
export (float) var speed = 3 # tiles per second

onready var segments_parent: Node2D = $segments_parent
onready var current_direction = Vector2.RIGHT
onready var next_direction = Vector2.ZERO
onready var target_tile_position = Vector2.ZERO

var should_move = true

func _ready():
	place_at_tile_position(tile_position)
	target_tile_position = _get_random_tile_position()
	connect("completed_move", self, "_on_completed_move")
	add_to_group(Game.groups.roots.snake)
	Game.world_service.connect_snake_signals(self)


func _process(delta):
	if should_move:
		if target_tile_position == tile_position:
			_target_captured()
		move()
		
		
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
		
		
func move():
	should_move = false
	next_direction = _get_a_star_next_direction()
	var next_tile_position = tile_position + next_direction
	move_to_tile_position(next_tile_position, speed)
	move_segments()
	current_direction = next_direction
	
	
func move_segments():
	var next_segment_position = tile_position
	var previous_segment_position
	
	var segments = segments_parent.get_children()
	for segment_child in segments:
		var snake_segment = segment_child as SnakeSegment
		if not snake_segment:
			continue
			
		previous_segment_position = snake_segment.tile_position
		snake_segment.move_to_tile_position(next_segment_position, speed)
		next_segment_position = previous_segment_position
	
	
func _on_completed_move(old_tile_position: Vector2, new_tile_position: Vector2) -> void:
	should_move = true
	

func _get_a_star_next_direction():
	var route_to_target = Game.world_service.calculate_route_between_points(tile_position, target_tile_position)
	if route_to_target.empty():
		return current_direction
	return route_to_target[0] - tile_position

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
	target_tile_position = _get_random_tile_position()
	var spawned_tile_position = previous_tile_position
	var segment_children = segments_parent.get_children()
	
	if not segment_children.empty():
		var last_child = segment_children.back()
		var last_segment = last_child as SnakeSegment
		if last_segment:
			spawned_tile_position = last_segment.previous_tile_position
			
	var snake_segment_node = segment_scene.instance()
	segments_parent.add_child(snake_segment_node)
	snake_segment_node.place_at_tile_position(spawned_tile_position)

