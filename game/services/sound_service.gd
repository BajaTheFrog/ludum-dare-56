extends GameService
class_name SoundService

const MASTER_BUS_NAME = "Master"
const MUSIC_BUS_NAME ="Music"
const SFX_BUS_NAME = "SFX"

const MASTER_VOLUME_DEFAULT = 1.0 # range is 0 - 2.0
const MASTER_VOLUME_MAX = 2.0
const MUSIC_VOLUME_DEFAULT = 1.0 # range is 0 - 2.0
const MUSIC_VOLUME_MAX = 2.0
const SFX_VOLUME_DEFAULT = 1.0 # range is 0 - 2.0
const SFX_VOLUME_MAX = 2.0
const MUTE_DEFAULT = false 

signal settings_updated()

var _master_volume = MASTER_VOLUME_DEFAULT
var _music_volume = MUSIC_VOLUME_DEFAULT
var _sfx_volume = SFX_VOLUME_DEFAULT
var _is_mute_enabled = MUTE_DEFAULT

func on_game_initialize():
	.on_game_initialize()
	set_mute_value(_is_mute_enabled)
	

func get_master_volume_value() -> float:
	return get_volume_value(_master_volume, MASTER_VOLUME_MAX)
	

func get_master_volume_scalar() -> float:
	return get_volume_scalar(_master_volume)
	
	
func set_master_volume_scalar(value: float):
	_master_volume = value * MASTER_VOLUME_MAX
	emit_signal("settings_updated")
	
	
func get_music_volume_value() -> float:
	return get_volume_value(_music_volume, MUSIC_VOLUME_MAX)
	

func get_music_volume_scalar() -> float:
	return get_volume_scalar(_music_volume) * get_master_volume_scalar()

	
func get_sfx_volume_value() -> float:
	return get_volume_value(_sfx_volume, SFX_VOLUME_MAX)
	

func get_sfx_volume_scalar() -> float:
	return get_volume_scalar(_sfx_volume) * get_master_volume_scalar()


func get_volume_value(value: float, max_value: float) -> float:
	return value / max_value
	
	
func get_volume_scalar(value: float) -> float:
	return value * get_mute_volume_scalar()


func get_mute_volume_scalar() -> float:
	return 1.0 if _is_mute_enabled else 0.0
	
	
func get_mute_value() -> bool:
	return _is_mute_enabled
	

func toggle_mute() -> void:
	set_mute_value(not _is_mute_enabled)


func set_mute_value(new_mute_value: bool):
	_is_mute_enabled = new_mute_value
	
	var bus_idx = AudioServer.get_bus_index(MASTER_BUS_NAME)
	AudioServer.set_bus_mute(bus_idx, _is_mute_enabled)
	
	emit_signal("settings_updated")


func _process(delta):
	if Input.is_action_just_pressed("toggle_mute"):
		toggle_mute()
