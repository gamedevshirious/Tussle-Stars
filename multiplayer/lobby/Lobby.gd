extends Control

# warning-ignore:unused_signal
#signal started

var my_info
var in_lobby = false

onready var _fetch = GotmLobbyFetch.new()
func _ready():
#	globals.players = {}
# warning-ignore:return_value_discarded
	Gotm.connect("lobby_changed", self, "_on_Gotm_lobby_changed")
# warning-ignore:return_value_discarded
	gamestate.connect("connection_failed", self, "_on_connection_failed")
# warning-ignore:return_value_discarded
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
# warning-ignore:return_value_discarded
	gamestate.connect("player_list_changed", self, "refresh_player_list")
# warning-ignore:return_value_discarded
	gamestate.connect("game_ended", self, "_on_game_ended")
# warning-ignore:return_value_discarded
	gamestate.connect("game_error", self, "_on_game_error")

	my_info = {
		"name": globals.player_name,
		"hero": globals.curr_hero,
		"color": globals.color
	}
#	$Game.hide()
#	$LobbyEntry.hide()
	refresh()
#	$Lobbies/Host/Host/Label.text = "Host"
#	_on_Refresh_clicked(null)

func _on_connection_failed():
	pass

func _on_connection_success():
	pass


func _on_game_ended():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://game_scenes/MainMenu.tscn")

func _on_game_error():
	print_debug("Game Error")
	get_tree().paused = true

func _on_LobbyEntry_selected(lobby):
#	print_debug("joined")
#	hide()
#	$Game.show()
	in_lobby = true
#	$Game/Spinner.show()
	var success = yield(lobby.join(), "completed")
#	$Game/Spinner.hide()
	if success:
		$Lobbies/Host/Host.hide()
		$Lobbies/Host/Refresh.hide()
		$Lobbies/List/Title.hide()
#		$Background.hide()
		$Lobbies/Host/Name.text = "Tell host to start ... reeeeeee"

		gamestate.join_game(Gotm.lobby.host.address, my_info)
#		join()
#		emit_signal("joined")
	else:
		push_error("Failed to connect to lobby '" + lobby.name + "'!")
		$Lobbies.show()
#		$Game.hide()


func _on_Host_pressed():
#	hide()
#	$Game.show()

	in_lobby = true

	if len($Lobbies/Host/Name.text) <= 0:
		return
# warning-ignore:return_value_discarded
	Gotm.host_lobby(false)
	Gotm.lobby.hidden = false
	Gotm.lobby.name = $Lobbies/Host/Name.text

#	$Background.hide()
	$Lobbies/Host/Host.hide()
	$Lobbies/Host/Name.editable = false
	$Lobbies/Host/Refresh.hide()
	$StartGame.show()
	$Lobbies/Host/CopyLink.show()
	$Lobbies/List/Title.hide()

	gamestate.host_game(my_info)
	refresh_player_list()

#	host()
#	get_parent().host()
#	emit_signal("hosted")
#	$Lobbies/Host/Host.queue_free()
#	$Lobbies/Host/Refresh.queue_free()
#	$Lobbies/Host/Name.text = "Waiting for players ..."

func refresh():
#	$Lobbies/List/Spinner.show()
	if not in_lobby:
		for child in $Lobbies/List/Entries.get_children():
			child.queue_free()

		var lobbies = yield(_fetch.first(5), "completed")
	
		for i in range(lobbies.size()):
			var lobby = lobbies[i]
			var node = $LobbyEntry.duplicate()
	#		var node = preload("res://multiplayer/lobby/components/LobbyEntry/LobbyEntry.tscn").instance()
			node.show()
	#		node.connect("selected", self, "_on_LobbyEntry_selected")
			$Lobbies/List/Entries.add_child(node)
			node.set_lobby(lobby)
	else:
		refresh_player_list()
#		node.rect_position.y += i * 80

#	$Lobbies/List/Spinner.hide()


func _on_Gotm_lobby_changed():
	if not Gotm.lobby:
		$Lobbies.show()
#		$Game.hide()

func _on_Refresh_pressed():
	refresh()

func refresh_player_list():
	$Lobbies/List/Entries.hide()
	$PlayersList.show()

	var players = gamestate.get_player_list()
	players.sort()
	for child in get_node("PlayersList/Players").get_children():
		child.queue_free()
	var lbl = preload("res://game_scenes/helper/PlayerLabel.tscn").instance()
	lbl.text = str(gamestate.get_player_info())
	get_node("PlayersList/Players").add_child(lbl)
	for p in gamestate.players.keys():
		var xlbl = lbl.duplicate()
		xlbl.text = str(gamestate.players[p]["name"])
		get_node("PlayersList/Players").add_child(xlbl)

#	get_node("Lobbies/List/Players").disabled=not get_tree().is_network_server()


#
#func host():
#	var peer = NetworkedMultiplayerENet.new()
#	peer.create_server(globals.PORT)
#	get_tree().set_network_peer(peer)
#	get_tree().network_peer=peer

#	get_tree().emit_signal("network_peer_connected")
# warning-ignore:return_value_discarded
#	get_tree().connect("network_peer_connected", get_parent(), "_player_connected")
#	print_debug(get_tree().get_network_unique_id())
#	_init()
#	print_debug("hosted")
#	get_parent()._init_game(1, globals.curr_shape, globals.curr_hero)

#	queue_free()
#
#func join():
#	var peer = NetworkedMultiplayerENet.new()
##	print_debug(Gotm.lobby.host.address)
#	peer.create_client(Gotm.lobby.host.address, globals.PORT)
##	get_tree().set_network_peer(peer)
#	get_tree().network_peer = peer

#	get_tree().emit_signal("network_peer_connected")
#	yield(get_tree(), "connected_to_server")
#	print_debug("joined")


func _on_StartGame_pressed():
	Gotm.lobby.hidden = true
#	Gotm.lobby.leave()
	gamestate.begin_game()


func _on_Quit_pressed():
	in_lobby = false
	if in_lobby:
		Gotm.lobby.leave()
	get_tree().change_scene("res://game_scenes/MainMenu.tscn")


func _on_CopyLink_pressed():
	if in_lobby:
		print_debug(Gotm.lobby.invite_link)
		OS.set_clipboard(Gotm.lobby.invite_link)

