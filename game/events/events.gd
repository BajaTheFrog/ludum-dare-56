extends Node
class_name Events

onready var application: ApplicationEvents = ApplicationEvents.new()
onready var player: PlayerEvents = PlayerEvents.new()
onready var snake: SnakeEvents = SnakeEvents.new()
onready var game_round: RoundEvents = RoundEvents.new()
onready var game_theme: GameThemeEvents = GameThemeEvents.new()


class ApplicationEvents:
	signal pause_changed(is_paused)
	

class PlayerEvents:
	signal player_picked_up_apple()
	signal server_player_died(player)
	signal client_player_died(player)
	signal client_active_player_died()
	signal server_player_respawned(player)
	signal client_player_respawned(player)
	signal client_active_player_respawned()
	signal client_active_player_respawn_time_remaining()
	

class SnakeEvents:
	signal target_captured()
	signal snake_doomed() # eats itself
	signal completed_body_move()
	signal caught_player(body)
	signal snake_killed() # by player bomb
	

class RoundEvents:
	signal new_target_placed(target_tile_position)
	signal new_round_state_data(round_state_data)
	
	
class GameThemeEvents:
	signal theme_changed(new_theme)
