extends Control

var heroes = []
var hero_index = 0

var dir

func _process(_delta):
	pass

func _ready():
	globals.player_name = globals.save_game["player_name"]
	$TypeSelector/PlayerNameLabel.text = globals.player_name

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
	load_curr_hero()
#	for i in $TypeSelector/heros.get_item_count():
#		$TypeSelector/heros.remove_item(0)
#
#	for i in heroes:
#		$TypeSelector/heros.add_item(i)
func load_curr_hero():
	$TypeSelector/sprite.texture = load("res://characters/"+heroes[hero_index]+"/head.png")

func _on_SinglePlayer_pressed():
	globals.curr_hero = heroes[hero_index]
	globals.mode = "singleplayer"
	globals.player_name = $TypeSelector/PlayerNameLabel.text
	get_tree().change_scene("res://game_scenes/levels/Dojo.tscn")

func _on_Prev_pressed():
	hero_index = (hero_index - 1) % heroes.size()
	load_curr_hero()

func _on_Next_pressed():
	hero_index = (hero_index - 1) % heroes.size()
	load_curr_hero()

func _on_Multiplayer_pressed():
	globals.curr_hero = heroes[hero_index]
	globals.mode = "multiplayer"
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://game_scenes/root.tscn"))



func _on_LineEdit_text_changed(new_text):
	globals.save_game["player_name"] = new_text
	globals.save_data()

