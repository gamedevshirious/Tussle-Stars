extends KinematicBody

const MOVE_SPEED = 12
const JUMP_FORCE = 50
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30

const H_LOOK_SENS = 1.0
const V_LOOK_SENS = .1

onready var tpcam = $CameraBase/TPCamera
onready var fpcam = $Mesh/head/head/FPCamera
var cam
var zoomed_in = false

var y_velo = 0
var move_vec = Vector3()

puppet var _move_vec = Vector3()
puppet var _rotation = Vector3()

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


func set_player_info(info):
	my_info = info

func _ready():
#	$AnimationPlayer.play("idle")
	if is_network_master():
		cam = tpcam
		cam.current = true
		select_script()
	else:
		$HUD.queue_free()
		$CameraBase.queue_free()
		
	var rgb = my_info["color"].split(',') 

	var material = $Mesh/head/head.get_surface_material(0).duplicate()
	material.set_shader_param("base_color", Color(rgb[0], rgb[1], rgb[2], rgb[3]))
	for node in meshes:
		get_node(node).set_surface_material(0, material)
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func select_script():
	print(my_info["hero"])
	print(globals.heroes)
	if (globals.heroes[my_info["hero"]]["scripts"]["movement"] == "default"):
		$scripts/movement.set_script(load("res://characters/player/movement.gd"))
	else:
		$scripts/movement.set_script(load("res://characters/heroes/"+my_info["hero"]+"/movement.gd"))

	if (globals.heroes[my_info["hero"]]["scripts"]["abilities"] == "default"):
		$scripts/abilities.set_script(load("res://characters/player/abilities.gd"))
	else:
		$scripts/abilities.set_script(load("res://characters/heroes/"+my_info["hero"]+"/abilities.gd"))



func _input(event):
	if is_network_master():
		if event.is_action_pressed("change_camera"):
			cam = fpcam if cam != fpcam else tpcam
			cam.current = true
			zoomed_in = false if cam != fpcam else true
		if event is InputEventMouseMotion or event is InputEventScreenDrag:
			cam.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
			cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, 0, 30)# if cam == fpcam else clamp(cam.rotation_degrees.x, 0, 30)
	#		$CameraBase/Gun.rotation_degrees.z = cam.rotation_degrees.x
			rotation_degrees.y -= event.relative.x * H_LOOK_SENS


func _process(_delta):
	move()
#	$CameraBase/Crosshair.visible = zoomed_in
func move():
	if is_network_master():
		$scripts/movement.move(self)

		if Input.is_action_just_pressed("shoot"):
			rpc("quick")

		rset("_move_vec", translation)
		rset("_rotation", rotation_degrees)
	else:
		translation = _move_vec
		rotation_degrees = _rotation

sync func quick():
	$StatusLabel.text = "shoot"
	$scripts/abilities.quick(self)

#func play_anim(name):
#	pass
#	if anim.get_current_node() == name:
#		return
#	anim.travel(name)
