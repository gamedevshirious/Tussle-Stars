extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var path = "res://characters/player/player.tscn"
	print(path)
	var player = load(path).instance()
	player.set_script(load("res://characters/player/singleplayer.gd"))
	$players.add_child(player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
