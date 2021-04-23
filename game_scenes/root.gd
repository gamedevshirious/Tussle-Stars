extends Node

#remotesync func pre_configure_game():
#	$lobby.hide()
#	var selfPeerID = get_tree().get_network_unique_id()
#
#	# Load world
#	var world = load("res://game_scenes/World.tscn").instance()
#	world.name = "world"
#	get_node("/root").add_child(world)
#
#	# Load my player
#	var my_player = load("res://characters/"+globals.curr_shape+"/"+globals.curr_hero+"/Player.tscn").instance()
#	my_player.set_script(load("res://characters/"+globals.curr_shape+"/"+globals.curr_hero+"/multiplayer.gd"))
#	my_player.set_name(str(selfPeerID))
#	my_player.set_network_master(selfPeerID) # Will be explained later
#	get_node("/root/world/players").add_child(my_player)
#
#	# Load other players
#	for p in globals.players:
#		var player = load("res://characters/"+globals.players[p]["shape"]+"/"+globals.players[p]["hero"]+"/Player.tscn").instance()
#		player.set_script(load("res://characters/"+globals.players[p]["shape"]+"/"+globals.players[p]["hero"]+"/multiplayer.gd"))
#		player.set_name(str(p))
#		player.set_network_master(int(p)) # Will be explained later
#		get_node("/root/world/players").add_child(player)
#
#	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
##	rpc_id(1, "done_preconfiguring", selfPeerID)
#
#
#func _on_lobby_started():
##	print_debug(globals.players)
#	rpc("pre_configure_game")
