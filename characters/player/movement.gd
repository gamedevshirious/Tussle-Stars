extends Node

var lookSensitivity : float = 15.0
var minLookAngle : float = -20.0
var maxLookAngle : float = 75.0
 
var mouseDelta : Vector2 = Vector2()

const MOVE_SPEED = 12
const JUMP_FORCE = 55
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30

const H_LOOK_SENS = 1.0
const V_LOOK_SENS = 1.0

var y_velo = 0
var _self 
var mesh

func _init():
	_self = get_parent().get_parent()
	mesh = _self.get_node("Mesh")
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func move(delta):
	var screen_pos = get_viewport().get_camera().unproject_position(_self.global_transform.origin)
	var mouse_pos = get_viewport().get_mouse_position()
	var angle = screen_pos.angle_to_point(mouse_pos)
#	_self.rotation.y = -angle 
	
	var move_vec = Vector3()
	if Input.is_action_pressed("ui_up"):
		move_vec.z -= 1
		_self.rotation.y = lerp_angle(_self.rotation.y, _self.cam.rotation.y, 0.1)
	if Input.is_action_pressed("ui_down"):
		move_vec.z += 1
	if Input.is_action_pressed("ui_right"):
		move_vec.x += 1
	if Input.is_action_pressed("ui_left"):
		move_vec.x -= 1
		
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), _self.rotation.y)
	move_vec *= MOVE_SPEED
	move_vec.y = y_velo
	_self.move_and_slide(move_vec, Vector3(0, 1, 0))
	
	var grounded = _self.is_on_floor()
	y_velo -= GRAVITY
	var just_jumped = false
	if grounded and Input.is_action_just_pressed("ui_accept"):
		just_jumped = true
		y_velo = JUMP_FORCE
	if grounded and y_velo <= 0:
		y_velo = -0.1
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED
	
