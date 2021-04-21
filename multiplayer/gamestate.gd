extends Node

# Default game port
const DEFAULT_PORT = 10567

# Max number of players
const MAX_PEERS = 12

# Name for my player
var player_info = {}
# Names for remote players in id:name format
var players = {}

# Signals to let lobby GUI know what's going on
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# Callback from SceneTree
# warning-ignore:unused_argument
func _player_connected(id):
	# This is not used in this demo, because _connected_ok is called for clients
	# on success and will do the job.
	pass

# Callback from SceneTree
func _player_disconnected(id):
	if (get_tree().is_network_server()):
		if (has_node("/root/world")): # Game is in progress
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
		else: # Game is not in progress
			# If we are the server, send to the new dude all the already registered players
			unregister_player(id)
			for p_id in players:
				# Erase in the server
				rpc_id(p_id, "unregister_player", id)

# Callback from SceneTree, only for clients (not server)
func _connected_ok():
	# Registration of a client beings here, tell everyone that we are here
	rpc("register_player", get_tree().get_network_unique_id(), player_info)
	emit_signal("connection_succeeded")

# Callback from SceneTree, only for clients (not server)
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()
	get_tree().paused = true

# Callback from SceneTree, only for clients (not server)
func _connected_fail():
	get_tree().paused = true
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")

# Lobby management functions

remote func register_player(id, new_player_info):
	if (get_tree().is_network_server()):
		# If we are the server, let everyone know about the new player
		rpc_id(id, "register_player", 1, player_info) # Send myself to new dude
		for p_id in players: # Then, for each remote player
			rpc_id(id, "register_player", p_id, players[p_id]) # Send player to new dude
			rpc_id(p_id, "register_player", id, new_player_info) # Send new dude to player

	players[id] = new_player_info
	emit_signal("player_list_changed")

remote func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")

remote func pre_start_game(spawn_points):
	# Change scene
	var world = load("res://game_scenes/levels/World.tscn").instance()
	get_tree().get_root().get_node("root").add_child(world)

#	print_debug(get_tree().get_root())
	get_tree().get_root().get_node("root").get_node("lobby").hide()

	for p_id in spawn_points:
		var info

		if (p_id == get_tree().get_network_unique_id()):
			# If node for this peer id, set name
			info = player_info
		else:
			# Otherwise set name from peer
			info = players[p_id]

		var player_scene = load("res://characters/player/player.tscn")
		var spawn_pos = world.get_node("spawn_points/" + str(spawn_points[p_id])).translation
		var player = player_scene.instance()

		player.set_name(str(p_id)) # Use unique ID as node name
		player.translation=spawn_pos
		player.set_player_info(info)
		player.set_network_master(p_id) #set unique id as master

		world.get_node("players").add_child(player)

	# Set up score
#	world.get_node("score").add_player(get_tree().get_network_unique_id(), player_info)
#	for pn in players:
#		world.get_node("score").add_player(pn, players[pn])

	if (not get_tree().is_network_server()):
		# Tell server we are ready to start
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()

remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!

var players_ready = []

remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if (not id in players_ready):
		players_ready.append(id)

	if (players_ready.size() == players.size()):
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()

func host_game(new_player_info):
	player_info = new_player_info
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().network_peer = host

func join_game(ip, new_player_info):
	player_info = new_player_info
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, DEFAULT_PORT)
#	host.create_client("127.0.0.1", DEFAULT_PORT)
	get_tree().network_peer = host

func get_player_list():
	return players.values()

func get_player_info():
	return globals.player_name

func begin_game():
	assert(get_tree().is_network_server())

	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	# Call to pre-start game with the spawn points
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points)


	pre_start_game(spawn_points)

func end_game():
	if (has_node("World")): # Game is in progress
		# End it
		get_node("World").queue_free()

	get_tree().set_network_peer(null) # End networking
	players.clear()
	emit_signal("game_ended")

func _ready():
	players.clear()
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_ok")
# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connected_fail")
# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")
