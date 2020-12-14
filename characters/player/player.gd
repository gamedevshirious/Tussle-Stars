extends KinematicBody

const MOVE_SPEED = 12
const JUMP_FORCE = 30
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
	"Mesh/torso/left/elbow/hand",
	"Mesh/torso/right/upper",
	"Mesh/torso/right/elbow/hand",
	"Mesh/legs/right/upper",
	"Mesh/legs/right/knee/lower",
	"Mesh/legs/left/upper",
	"Mesh/legs/left/knee/lower"
]


func set_player_info(info):
	my_info = info
	
func _ready():	
	if is_network_master():
		cam = tpcam
		cam.current = true
	var material = $Mesh/head/head.get_surface_material(0).duplicate()
	material.set_shader_param("base_color", str2var(my_info["color"]))
	for node in meshes:
		get_node(node).set_surface_material(0, material)
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if is_network_master():
		if event.is_action_pressed("change_camera"):
			cam = fpcam if cam != fpcam else tpcam
			cam.current = true
			zoomed_in = false if cam != fpcam else true
		if event is InputEventMouseMotion:
			cam.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
			cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, 0, 30)# if cam == fpcam else clamp(cam.rotation_degrees.x, 0, 30)
	#		$CameraBase/Gun.rotation_degrees.z = cam.rotation_degrees.x
			rotation_degrees.y -= event.relative.x * H_LOOK_SENS

func _process(_delta):
	move()
#	$CameraBase/Crosshair.visible = zoomed_in
func move():
	if is_network_master():
		move_vec = Vector3()
		if Input.is_action_pressed("ui_up"):
			move_vec.z -= 1
		if Input.is_action_pressed("ui_down"):
			move_vec.z += 1
		if Input.is_action_pressed("ui_right"):
			move_vec.x += 1
		if Input.is_action_pressed("ui_left"):
			move_vec.x -= 1
		move_vec = move_vec.normalized()
		move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
		move_vec *= MOVE_SPEED
		move_vec.y = y_velo
		move_vec = move_and_slide(move_vec, Vector3(0, 1, 0))

		var grounded = is_on_floor()
		y_velo -= GRAVITY
		var just_jumped = false
		if grounded and Input.is_action_just_pressed("jump"):
			just_jumped = true
			y_velo = JUMP_FORCE
			
		if grounded and y_velo <= 0:
			y_velo = -0.1
		if y_velo < -MAX_FALL_SPEED:
			y_velo = -MAX_FALL_SPEED

		if Input.is_action_just_pressed("focus"):
			if cam.name == "TPCamera":
				if not zoomed_in:
					cam.translation = Vector3(3, 4, 4)
					zoomed_in = true
				else:
					cam.translation = Vector3(0, 4, 8)
					zoomed_in = false
		
		rset("_move_vec", translation)
		rset("_rotation", rotation_degrees)
	else:
		translation = _move_vec
		rotation_degrees = _rotation

func play_anim(name):
	pass
#	if anim.get_current_node() == name:
#		return
#	anim.travel(name)
