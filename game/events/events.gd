extends Node
class_name Events

onready var application: ApplicationEvents = ApplicationEvents.new()
onready var settings: SettingsEvents = SettingsEvents.new()
onready var player: PlayerEvents = PlayerEvents.new()
onready var enemies: EnemyEvents = EnemyEvents.new()
onready var snake: SnakeEvents = SnakeEvents.new()
onready var game_round: RoundEvents = RoundEvents.new()
onready var game_theme: GameThemeEvents = GameThemeEvents.new()


class ApplicationEvents:
	signal pause_changed(is_paused)
	
	
class SettingsEvents:
	# signal volume_changed()
	# signal screenshake_changed()
	pass


class PlayerEvents:
	# signal player_spawned()
	# signal player_hit()
	# signal player_died()
	pass


class EnemyEvents:
	# signal enemy_spawned()
	# signal enemy_died()
	pass

class SnakeEvents:
	signal target_captured()
	

class RoundEvents:
	signal new_target_placed(target_tile_position)
	
	
class GameThemeEvents:
	signal theme_changed(new_theme)
