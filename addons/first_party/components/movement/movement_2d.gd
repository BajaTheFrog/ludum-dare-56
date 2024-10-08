extends Component
class_name Movement2D

# Movment math inspired by
# https://github.com/ShatReal/Game-Jam-Template-4/blob/master/scenes/players/player_top_down.gd

enum CollisionType { COLLIDE, SLIDE }

signal velocity_changed(velocity)

export (NodePath) var target_path = null
export (CollisionType) var collision_type = CollisionType.COLLIDE
export (float) var gravity = 0.0
# TODO: Make a simpler version that has the speed and direction built in
export (NodePath) var speed_calculator_path
export (NodePath) var direction_calculator_path

func _speed_calculator() -> Node:
	return get_node(speed_calculator_path)
	

func _direction_calculator() -> Node:
	return get_node(direction_calculator_path)
	

onready var velocity = Vector2.ZERO

var assigned_target: KinematicBody2D = null

func _get_target() -> KinematicBody2D:
	if assigned_target:
		return assigned_target
		
	var exported_target = get_node(target_path) as KinematicBody2D
	if exported_target:
		return exported_target
		
	return null


func reset():
	hard_stop()


func _component_physics_process(delta):
	var target = _get_target()
	if not target:
		return

	var speed_calc = _speed_calculator()
	var top_speed = speed_calc.top_speed
	var next_direction = _direction_calculator().get_current_direction()
	var direction_responsiveness = _direction_calculator().direction_change_responsiveness

	if speed_calc.has_acceleration:
		if next_direction.length() == 0.0:
			velocity = velocity.move_toward(Vector2.ZERO, speed_calc.deacceleration * delta)
		else:
			velocity = velocity.move_toward(next_direction * top_speed, speed_calc.acceleration * delta)
			# Adjust the actual velocity heading based on responsiveness
			# even if length stays the same
			var current_speed = velocity.length()
			var current_heading = velocity.normalized()
			var adjusted_heading = lerp(current_heading, next_direction, direction_responsiveness)
			velocity = adjusted_heading.normalized() * current_speed
		
	else:
		velocity = next_direction * top_speed
	
	velocity.y += gravity * delta
	
	match collision_type:
		CollisionType.COLLIDE:
			var collision_info = target.move_and_collide(velocity * delta)
		CollisionType.SLIDE:
			velocity = target.move_and_slide(velocity, Vector2(0, -1))
	
	_set_velocity(velocity)


func hard_stop():
	_set_velocity(Vector2.ZERO)


func _set_velocity(vector: Vector2):
	velocity = vector
	emit_signal("velocity_changed", velocity)
