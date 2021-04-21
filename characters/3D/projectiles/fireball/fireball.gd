extends KinematicBody

const BULLET_VELOCITY = 200

var time_alive = 5
var hit = false

onready var collision_shape = $CollisionShape

func _physics_process(delta):
	time_alive -= delta

	if time_alive < 0:
		queue_free()
		
	var col = move_and_collide(-delta * BULLET_VELOCITY * transform.basis.z)
	if col:
		if col.collider and col.collider.has_method("damage"):
			col.collider.damage(10, "burn")
		
		queue_free()
	
#
#const DESPAWN_TIME = 500
##
#var timer = 0
##var velocity = Vector3()
##var bullet_velocity = 5
#
#func _ready():
#	print_debug("bullet spawned")
#	set_physics_process(false)
##
##
##func _physics_process(delta):
##	timer += delta
##	if timer > DESPAWN_TIME:
##		queue_free()
##		timer = 0
##	var collision = move_and_collide(velocity)
##	if collision != null:
##		queue_free()
##
#func shoot(point):
#	if (point != null):
#		transform = transform.looking_at(point, Vector3.UP)
#		set_physics_process(true)
#
#func _physics_process(delta):
#	timer += delta
#	if timer > DESPAWN_TIME:
#		queue_free()
#		timer = 0
#
#	var bullet_speed = .1
#	translate_object_local(Vector3(0, 0, -bullet_speed))	
