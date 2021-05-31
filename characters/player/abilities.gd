extends Node


var bullet_speed = 10

func quick(_self, shoot_origin, shoot_dir):
	var b = preload("res://characters/3D/projectiles/fireball/fireball.tscn").instance()
	get_tree().get_root().add_child(b)
	
	b.global_transform.origin = shoot_origin
			# If we don't rotate the bullets there is no useful way to control the particles ..
	b.look_at(shoot_origin + shoot_dir, Vector3.UP)

	b.add_collision_exception_with(_self)
