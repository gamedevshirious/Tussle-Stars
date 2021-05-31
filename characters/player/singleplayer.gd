extends KinematicBody

const MOVE_SPEED = 12
const JUMP_FORCE = 50
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30

const H_LOOK_SENS = .1
const V_LOOK_SENS = .1

onready var tpcam = $TPCameraBase
onready var fpcam = $Mesh/head/head/FPCameraBase
var cam
var zoomed_in = false

var HP = 100

puppet var _move_vec = Vector3()
puppet var _rotation = Vector3()
puppet var _mesh_rotation = Vector3()
puppet var _hp = 100

var world_point = Vector3(-1, -1, -1)

onready var shoot_from = get_node("Mesh/torso/Muzzle")
onready var crosshair = $TPCameraBase/Camera/cross

var my_info = {}

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
	my_info = {
		"name": globals.player_name,
		"color": globals.color
	}
	
	cam = tpcam
	cam.get_node("Camera").current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$HUD/LeaveButton.text = "Stop"
	
	$HealthBar/Viewport/ProgressBar.value = HP
	
	select_script()
		
	var rgba = my_info["color"].split(',') 
	update_color(rgba)
	
	
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$DirectionalLight.queue_free()

func update_color(rgb):
	var material = $Mesh/head/head.get_surface_material(0).duplicate()
	material.set_shader_param("base_color", Color(rgb[0], rgb[1], rgb[2], rgb[3]))
	for node in meshes:
		get_node(node).set_surface_material(0, material)

func select_script():
	$scripts/movement.set_script(load("res://characters/player/movement.gd"))
	$scripts/abilities.set_script(load("res://characters/player/abilities.gd"))
#	print(my_info["hero"])
#	print(globals.heroes)
#	if (globals.heroes[my_info["hero"]]["scripts"]["movement"] == "default"):
#		
##		$scripts/movement.set_script(load("user://movement.gd"))
#	else:
#		$scripts/movement.set_script(load("res://characters/heroes/"+my_info["hero"]+"/movement.gd"))
#
#	if (globals.heroes[my_info["hero"]]["scripts"]["abilities"] == "default"):
#		
#	else:
#		$scripts/abilities.set_script(load("res://characters/heroes/"+my_info["hero"]+"/abilities.gd"))


#
func _input(event):	
	if event.is_action_pressed("quit"):
		leave()
	
	if event.is_action_pressed("change_camera"):
		if cam != fpcam:
			cam = fpcam 
		else:
			cam = tpcam
		cam.get_node("Camera").current = true
		
#			zoomed_in = false if cam != fpcam else true

	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		cam.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
#			cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)# if cam == fpcam else clamp(cam.rotation_degrees.x, 0, 30)
#		$CameraBase/Gun.rotation_degrees.z = cam.rotation_degrees.x
		cam.rotation_degrees.y -= event.relative.x * H_LOOK_SENS
#			cam.rotation_degrees.y = clamp(cam.rotation_degrees.y, -120, -60)
		rotate_y(event.relative.x * -.01)
#			ray.global_transform.origin = cam.get_node("Camera").project_ray_origin(event.position)


func _process(delta):
	move(delta)
	
	# $Mesh/torso/Muzzle.rotation_degrees.x = cam.rotation_degrees.x
#	$CameraBase/Crosshair.visible = zoomed_in
func move(delta):
	
	$scripts/movement.move(delta)
	
	if Input.is_action_just_pressed("shoot"):
		if cam != fpcam:
			$scripts/movement.reset(cam, delta)
			
		var shoot_origin = shoot_from.global_transform.origin

		var ch_pos = crosshair.rect_position + crosshair.rect_size * 0.5
		var ray_from = cam.get_node("Camera").project_ray_origin(ch_pos)
		var ray_dir = cam.get_node("Camera").project_ray_normal(ch_pos)

		var shoot_target
		var col = get_world().direct_space_state.intersect_ray(ray_from, ray_from + ray_dir * 1000, [self], 0b11)
		if col.empty():
			shoot_target = ray_from + ray_dir * 1000
		else:
			shoot_target = col.position
		var shoot_dir = (shoot_target - shoot_origin).normalized()		
		
		quick(shoot_origin, shoot_dir)
		
#			cam.get_node("Camera").add_trauma(0.35)
		
		

func quick(shoot_origin, shoot_dir):
	$scripts/abilities.quick(self, shoot_origin, shoot_dir)

func damage(hp, _status):
	HP -= hp
	
	if HP <= 0:
		var rgba = ["255", "255", "255", "1"]
		update_color(rgba)
		
		$head.disabled = true
		$body.disabled = true
		
#		rpc("notify", "other player died")
		
		leave()
	
	$HealthBar/Viewport/ProgressBar.value = HP


#func play_anim(name):
#	pass
#	if anim.get_current_node() == name:
#		return
#	anim.travel(name)

func leave():
	get_tree().change_scene("res://game_scenes/MainMenu.tscn")
	


func _on_LeaveButton_pressed():	
	leave()
