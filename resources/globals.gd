extends Node

var curr_hero = "kindler"
var player_name = "PlayerName"
var color = "ffffff"
var mode = "singleplayer"

#var players = {}

var SAVFILE = "user://save_game.json"

var save_game = {
	"player_name": "temp",
	"color": "ffffff"
}

func show_notification(msg):
	var n = load("res://game_scenes/ui/Notif.tscn").instance()
	add_child(n)
	n.show_notification(msg)
	

func _ready():
	load_data()

func save_data():
	var save_file = File.new()
	save_file.open(SAVFILE, File.WRITE)
	save_file.store_line(to_json(save_game))
	save_file.close()
	load_data()


func load_data():
	var save_file = File.new()
	if not save_file.file_exists(SAVFILE):
		save_data()
	save_file.open(SAVFILE, File.READ)
	save_game = parse_json(save_file.get_line())
	###
	player_name = save_game["player_name"]
	color = save_game["color"]


var heroes = {
	"kindler": {
		"description": "Fire in palms, more than in heart",
		"scripts": {
			"movement": "default",
			"abilities": "kindler"
		}
	}
}

