extends Node
class_name RoundState
# this is where we track whats going on in the game

const KEY_PLAYER_APPLE = "round.state.key.player.apple"
const KEY_PLAYER_DEATHS = "round.state.key.player.deaths"
const KEY_SNAKE_APPLES = "round.state.key.snake.apples"
const KEY_SNAKE_DEATHS = "round.state.key.snake.deaths"
const KEY_METER = "round.state.key.meter"
const KEY_STATUS = "round.state.key.status"

const METER_MIN = 0
const METER_MAX = 100
const METER_DEFAULT = 50

enum RoundStatus { IN_PROGRESS, MICE_WIN, SNAKE_WIN }

class RoundStateData:
	var total_player_apples_acquired = 0
	var total_player_deaths = 0
	var total_snake_apples_acquired = 0
	var total_snake_deaths = 0
	var meter = METER_DEFAULT # 0 == snake wins, 100 means mice win
	var status: int = RoundStatus.IN_PROGRESS
	
	func get_meter_percent() -> float:
		return float(meter) / float(METER_MAX)
		
	
var data = RoundStateData.new()

static func create_dictionary_from_data(p_data: RoundStateData) -> Dictionary:
	return {
		KEY_PLAYER_APPLE: p_data.total_player_apples_acquired, 
		KEY_PLAYER_DEATHS: p_data.total_player_deaths, 
		KEY_SNAKE_APPLES: p_data.total_snake_apples_acquired,
		KEY_SNAKE_DEATHS: p_data.total_snake_deaths,
		KEY_METER: p_data.meter,
		KEY_STATUS: p_data.status
	}
	
	
static func create_data_from_dictionary(dict: Dictionary) -> RoundStateData:
	var new_data = RoundStateData.new()
	new_data.total_player_apples_acquired = dict[KEY_PLAYER_APPLE]
	new_data.total_player_deaths = dict[KEY_PLAYER_DEATHS]
	new_data.total_snake_apples_acquired = dict[KEY_SNAKE_APPLES]
	new_data.total_snake_deaths = dict[KEY_SNAKE_DEATHS]
	new_data.meter = dict[KEY_METER]
	
	var status_value = dict[KEY_STATUS]
	match status_value:
		RoundStatus.IN_PROGRESS:
			new_data.status = RoundStatus.IN_PROGRESS
		RoundStatus.MICE_WIN:
			new_data.status = RoundStatus.MICE_WIN
		RoundStatus.SNAKE_WIN:
			new_data.status = RoundStatus.SNAKE_WIN
	
	return new_data


func _ready():
	Game.events.snake.connect("target_captured", self, "_on_target_captured")
	Game.events.snake.connect("snake_doomed", self, "_on_snake_doomed")
	Game.events.snake.connect("snake_killed", self, "_on_snake_killed")
	Game.events.player.connect("player_picked_up_apple", self, "_on_player_picked_up_apple")
	Game.events.player.connect("player_died", self, "_on_player_died")
	
	
func _on_target_captured():
	if data.status != RoundStatus.IN_PROGRESS:
		return 
		
	data.total_snake_apples_acquired += 1
	data.meter -= 5
	broadcast_latest()
	
	
func _on_snake_doomed():
	if data.status != RoundStatus.IN_PROGRESS:
		return 
		
	data.total_snake_deaths += 1
	data.meter += 10
	broadcast_latest()
	

func _on_snake_killed():
	if data.status != RoundStatus.IN_PROGRESS:
		return 
		
	data.total_snake_deaths += 1
	data.meter += 50
	broadcast_latest()
	

func _on_player_picked_up_apple():
	if data.status != RoundStatus.IN_PROGRESS:
		return 
		
	data.total_player_apples_acquired += 1 
	data.meter += 2
	broadcast_latest()
	

func _on_player_died():
	if data.status != RoundStatus.IN_PROGRESS:
		return 
		
	data.total_player_deaths += 1
	data.meter -= 20
	broadcast_latest()
	
	
func broadcast_latest():
	_update_status()
	
	if is_network_master():
		var dictionary = create_dictionary_from_data(data)
		rpc("_broadcast_latest", dictionary)
		
		
func _update_status():
#	if data.status == RoundStatus.IN_PROGRESS:
#		if data.total_player_apples_acquired >= 3:
#			data.status = RoundStatus.MICE_WIN
#		elif data.total_snake_apples_acquired >= 10:
#			data.status = RoundStatus.SNAKE_WIN
	data.meter = clamp(data.meter, METER_MIN, METER_MAX)

	if data.meter <= 0:
		data.status = RoundStatus.SNAKE_WIN
	elif data.meter >= 100:
		data.status = RoundStatus.MICE_WIN
			
	
	
	
puppetsync func _broadcast_latest(p_data_dictionary: Dictionary) -> void:
	var new_data = create_data_from_dictionary(p_data_dictionary)
	data = new_data
	Game.events.game_round.emit_signal("new_round_state_data", data)
