extends Node

func quick(_self):
	var b = preload("res://characters/3D/projectiles/fireball/fireball.tscn").instance()
	get_tree().get_root().add_child(b)
	b.transform = _self.get_node("Mesh/torso/Muzzle").global_transform
	b.velocity = -b.transform.basis.z * b.bullet_velocity
