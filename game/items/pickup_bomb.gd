extends Pickup
class_name BombPickup

var active = true

func _ready():
	add_to_group(Game.groups.roots.pickup_bomb)
	$pickup_hotbox.add_to_group(Game.groups.hotboxes.pickup_bomb)
	Game.events.player.connect("player_picked_up_apple", self, "_on_player_picked_up_apple")
	Game.connect("player_ready", self, "_on_player_ready")


func _on_pickup_hotbox_area_entered(area):
	if get_tree().is_network_server():
		if area.is_in_group(Game.groups.hotboxes.player_pickups):
			# Area is of a player
			var player = TriggerZone.get_owner_from(area) as Player
			if player and player.bomb_count == 0:
				rpc("remove_bomb")
				player.rpc("_update_bomb_count", player.bomb_count+1)
				print("Player " + player.get_name() + " picked up a bomb")

func _on_player_picked_up_apple():
	if is_network_master():
		if not active:
			var random_tile_position = Game.world_service.get_random_tile_position()
			rpc("spawn_bomb", random_tile_position)

puppetsync func remove_bomb():
	active = false
	$sprite.visible = false
	$pickup_hotbox.set_deferred("monitorable", false)
	$pickup_hotbox.set_deferred("monitoring", false)

puppetsync func spawn_bomb(pos: Vector2):
	Game.world_service.place_object_at_tile_position(self, pos)
	active = true
	$sprite.visible = true
	$pickup_hotbox.set_deferred("monitorable", true)
	$pickup_hotbox.set_deferred("monitoring", true)

func _on_player_ready(id):
	if is_network_master():
		if active:
			var pos = Game.world_service.get_tile_position_from_global(global_position)
			rpc_id(id, "spawn_bomb", pos)
		else:
			rpc_id(id, "remove_bomb")
