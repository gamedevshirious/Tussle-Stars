extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if globals.mode != "multiplayer":
		var player_scene = load("res://characters/player/player.tscn")
		var spawn_pos = get_node("spawn_points/" + str(0)).translation
		var player = player_scene.instance()
		player.cam.current = true
		get_node("players").add_child(player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
