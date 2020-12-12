extends Spatial

const BULLET_SPEED = 1
var bullet_scene = preload("res://3D/gun/bullet/Bullet.tscn")

func _ready():
	pass

func fire_weapon():
	var new_bullet = bullet_scene.instance()
	new_bullet.scale = Vector3.ONE
	get_tree().root.add_child(new_bullet)
	new_bullet.global_transform = $point.global_transform
	new_bullet.velocity = new_bullet.global_transform.basis.z * BULLET_SPEED

