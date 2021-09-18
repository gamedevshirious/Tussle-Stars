extends Control

var heroes = []
var hero_index = 0

var dir


var meshes = [
	"Mesh/head/head",
	"Mesh/torso/torso",
	"Mesh/torso/left/upper",
	"Mesh/torso/left/upper/elbow/hand",
	"Mesh/torso/right/upper",
	"Mesh/torso/right/upper/elbow/hand",
	"Mesh/legs/right/upper",
	"Mesh/legs/right/upper/knee/lower",
	"Mesh/legs/left/upper",
	"Mesh/legs/left/upper/knee/lower"
]

func _process(delta):
	$player.rotate_y(.5 * delta)
	
	if $Play.is_hovered():
		$Play.set("ctom_colors/font_color", Color(255, 255, 255, 255))
	else:
		$Play.set("custom_colors/font_color", Color("00cfff"))

func _ready():	
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	$player_details/ShadeColorPicker.rect_scale.y = .25
	
	globals.player_name = globals.save_game["player_name"]
	$player_details/PlayerNameLabel.text = globals.player_name
	
	$CSGBox/Camera.current = true
	
#	get_tree().connect("connection_succeeded", self, "_start_game")
	
	
#	$ShadeColorPicker.color = globals.save_game["color"]
	var rgb = globals.color.split(',')
	_on_ShadeColorPicker_color_changed(Color(rgb[0], rgb[1], rgb[2], rgb[3]))

	$player.get_node("HUD").queue_free()

	dir = Directory.new()
	load_shape()

func load_shape():
	dir.open("res://characters/")
	heroes = []
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not (file.begins_with("3D") or file.begins_with(".")) :
			heroes.append(file)

	dir.list_dir_end()


	# load_curr_hero()
#	for i in $heros.get_item_count():
#		$heros.remove_item(0)
#
#	for i in heroes:
#		$heros.add_item(i)
#func load_curr_hero():
#	$sprite.texture = load("res://characters/.head.png")

#func _on_Prev_pressed():
#	hero_index = (hero_index - 1) % heroes.size()
##	load_curr_hero()
#
#func _on_Next_pressed():
#	hero_index = (hero_index - 1) % heroes.size()
#	load_curr_hero()

func _on_Multiplayer_pressed():
#	var world = load("res://game_scenes/levels/World.tscn").instance()
#	get_tree().change_scene_to(world)
#
	globals.peer = null
	globals.show_notification("Let the play begin!")
	globals.mode = "multiplayer"
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://game_scenes/root.tscn"))



func _on_LineEdit_text_changed(new_text):
	globals.save_game["player_name"] = new_text
	globals.save_data()

func _on_ShadeColorPicker_color_changed(color):
#	$sprite.modulate = color
	globals.color = var2str(color)
	globals.save_game["color"] = color
	globals.save_data()
	
	var material = $player/Mesh/head/head.get_surface_material(0).duplicate()
	material.set_shader_param("base_color", color)
	for node in meshes:
		get_node("player/" + node).set_surface_material(0, material)

func _on_Deathmatch_pressed():
	var my_info = {
		"name": globals.player_name, "hero": globals.curr_hero,
		"color": globals.color,
		"network_id": str(get_tree().get_network_unique_id())
	}
	
	var fetch = GotmLobbyFetch.new()
	var lobbies = yield(fetch.first(1), "completed")
	for lobby in lobbies:
		print_debug(lobby.id)
		
	$Deathmatch.text = "Starting ..."
#	print_debug(lobbies[0].name)
	if not lobbies.empty():
		var success = yield(lobbies[0].join(), "completed")
		if success:
			gamestate.join_game(Gotm.lobby.host.address, my_info)
			get_tree().change_scene_to(load("res://game_scenes/root.tscn"))
			globals.show_notification("Starting soon...")
#			lobbies[0].hidden = true
	else:
		print("lobby hosted")
		Gotm.host_lobby()
		Gotm.lobby.name = my_info["name"]
		Gotm.lobby.hidden = false
		gamestate.host_game(my_info)
		
#		Gotm.lobby.connect("peer_joined", self, "_start_game")
		
		$Deathmatch.disabled = true
		$Deathmatch.text = "Starting ..."
	
#func _start_game(_peer):
#	globals.show_notification("Player connected")
#
#	Gotm.lobby.hidden = true
#	$GameStartTimer.start(2)
#
#func game_starts():
##	Gotm.lobby.locked = true
#	get_tree().change_scene_to(load("res://game_scenes/root.tscn"))
#	gamestate.begin_game()
##	print('\''+peer.address)
##	print(str(get_tree().get_network_unique_id()))
#
#
#func _on_GameStartTimer_timeout():
#	game_starts()

	


func _on_FeedbackLink_pressed():
	OS.shell_open("https://forms.gle/hxwssgdKHsnVRwqd6")

func _on_Singleplayer_pressed():
	globals.peer = null
	globals.show_notification("Let the play begin!")
	globals.mode = "singleplayer"
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://game_scenes/levels/Dojo.tscn"))


func _on_HostButton_pressed():
	if globals.hosted:
		$traditional_multiplayer/HostButton.text = "HOST"
		get_tree().set_network_peer(null)
		globals.hosted = false
		$traditional_multiplayer/IPAddressTextBox.editable = true 
		$traditional_multiplayer/JoinButton.disabled = false
		return
	
	
	var my_info = {
		"name": globals.player_name, "hero": globals.curr_hero,
		"color": globals.color,
#		"network_id": str(get_tree().get_network_unique_id())
	}
	$traditional_multiplayer/HostButton.text = "HOSTing..."
	gamestate.host_game(my_info)
	$traditional_multiplayer/HTTPRequest.request("https://api.ipify.org/?format=json")
#	$traditional_multiplayer/HTTPRequest.request("https://icanhazip.com/")

	$traditional_multiplayer/IPAddressTextBox.editable = false
	$traditional_multiplayer/JoinButton.disabled = true


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:	
		var json = parse_json(body.get_string_from_utf8())
		$traditional_multiplayer/HostButton.text = json.ip
		OS.clipboard = json.ip
	else:
		$traditional_multiplayer/HostButton.text = "127.0.0.1"
	
	globals.hosted = true


func _on_JoinButton_pressed():
	if $traditional_multiplayer/IPAddressTextBox.text == "":
		globals.show_notification("Enter IP")
		return

	var ip = $traditional_multiplayer/IPAddressTextBox.text
	if not ip.is_valid_ip_address():
		globals.show_notification("Enter Valid IP")
		return

	
	var my_info = {
		"name": globals.player_name, "hero": globals.curr_hero,
		"color": globals.color,
#		"network_id": str(get_tree().get_network_unique_id())
	}
	
	gamestate.join_game($traditional_multiplayer/IPAddressTextBox.text, my_info)
	get_tree().change_scene_to(load("res://game_scenes/root.tscn"))
