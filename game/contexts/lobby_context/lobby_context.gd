extends Context
class_name LobbyContext

const CONTEXT_ID = "context.lobby"

func context_id_string() -> String:
	return CONTEXT_ID


func _ready():
	# Called every time the node is added to the scene.
	Game.connect("connection_failed", self, "_on_connection_failed")
	Game.connect("connection_succeeded", self, "_on_connection_success")
	Game.connect("player_list_changed", self, "refresh_lobby")
	Game.connect("game_ended", self, "_on_game_ended")
	Game.connect("game_error", self, "_on_game_error")
	$Connect/Name.text = "Player"
	if OS.has_feature("web"):
		$Connect/Host.hide()
		$Connect/URLLabel.hide()
		$Connect/URL.hide()

		var host = JavaScript.eval("window.location.hostname")
		var port = JavaScript.eval("new URLSearchParams(window.location.search).get('ws_port')")
		if port == null:
			port = str(Game.DEFAULT_PORT)

		var protocol = "ws"
		if JavaScript.eval("window.location.protocol") == "https:":
			protocol = "wss"

		$Connect/URL.text = protocol + "://" + host + ":" + port



func _on_host_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	$Connect.hide()
	$Players.show()
	$Connect/ErrorLabel.text = ""

	var player_name = $Connect/Name.text
	Game.host_game(player_name)
	refresh_lobby()


func _on_join_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	var url = $Connect/URL.text

	$Connect/ErrorLabel.text = ""
	$Connect/Host.disabled = true
	$Connect/Join.disabled = true

	var player_name = $Connect/Name.text
	Game.join_game(url, player_name)


func _on_connection_success():
	$Connect.hide()
	$Players.show()


func _on_connection_failed():
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false
	$Connect/ErrorLabel.set_text("Connection failed.")


func _on_game_ended():
	$Connect.show()
	$Players.hide()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false


func _on_game_error(errtxt):
	$ErrorDialog.dialog_text = errtxt
	$ErrorDialog.popup_centered_minsize()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false


func refresh_lobby():
	var players = Game.get_player_list()
	players.sort()
	$Players/List.clear()
	for p in players:
		$Players/List.add_item(p)
	
	$Players/Start.disabled = false


func _on_start_pressed():
	Game.begin_game()

