extends KinematicBody

const DESPAWN_TIME = 5

var timer = 0
var velocity

func _ready():
	set_physics_process(true);


func _physics_process(delta):
	timer += delta
	if timer > DESPAWN_TIME:
		queue_free()
		timer = 0
	var collision = move_and_collide(velocity)
