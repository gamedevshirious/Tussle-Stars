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

func _ready():
	globals.player_name = globals.save_game["player_name"]
	$PlayerNameLabel.text = globals.player_name

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

func _on_SinglePlayer_pressed():
	globals.curr_hero = heroes[hero_index]
	globals.mode = "singleplayer"
	globals.player_name = $PlayerNameLabel.text
	get_tree().change_scene("res://game_scenes/levels/Dojo.tscn")
#
#func _on_Prev_pressed():
#	hero_index = (hero_index - 1) % heroes.size()
##	load_curr_hero()
#
#func _on_Next_pressed():
#	hero_index = (hero_index - 1) % heroes.size()
#	load_curr_hero()

func _on_Multiplayer_pressed():
	globals.curr_hero = heroes[hero_index]
	globals.mode = "multiplayer"
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://game_scenes/root.tscn"))



func _on_LineEdit_text_changed(new_text):
	globals.save_game["player_name"] = new_text
	globals.save_data()



func _on_ShadeColorPicker_color_changed(color):
#	$sprite.modulate = color
	globals.color = var2str(color)
	
	var material = $player/Mesh/head/head.get_surface_material(0).duplicate()
	material.set_shader_param("base_color", color)
	for node in meshes:
		get_node("player/" + node).set_surface_material(0, material)
