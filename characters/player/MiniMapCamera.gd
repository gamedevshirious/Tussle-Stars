extends Camera

onready var player = get_node("../../../../") ;

func _physics_process(_delta):
	translation = Vector3(player.translation.x, 75, player.translation.z)
	rotation_degrees.y = player.rotation_degrees.y
