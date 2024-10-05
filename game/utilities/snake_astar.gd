extends AStar2D
class_name SnakeAStar

onready var current_direction = Vector2.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _compute_cost(from_id: int, to_id: int) -> float:
	current_direction = Game.entity_service.get_snake_direction()
	var from = self.get_point_position(from_id)
	var to = self.get_point_position(to_id)
	var direction_of_movement = calculate_direction(from, to)
	var cost = (pow(direction_of_movement.x, 2) + pow(direction_of_movement.y, 2)) * self.get_point_weight_scale(to_id)
	if current_direction != direction_of_movement:
		cost *= 1.5
	if from == Game.entity_service.get_snake_positions()[0]:
		if direction_of_movement + current_direction == Vector2.ZERO:
			cost = INF
	return cost
	
func _estimate_cost(from_id: int, to_id: int) -> float:
	return _compute_cost(from_id, to_id)

func calculate_direction(from: Vector2, to: Vector2) -> Vector2:
	return to - from
