extends Node

var lookSensitivity : float = 15.0
var minLookAngle : float = -20.0
var maxLookAngle : float = 75.0
 
var mouseDelta : Vector2 = Vector2()

const MOVE_SPEED = 12
const JUMP_FORCE = 55
const GRAVITY = .98
const MAX_FALL_SPEED = 30
const ROTATIONINTERPOLATION = 10.0
const MOVEMENTINTERPOLATION = 15.0

const H_LOOK_SENS = 1.0
const V_LOOK_SENS = 1.0

var motion = Vector2()

var _self 
var mesh

var originBasis = Basis()
var orientation = Transform()
var velocity = Vector3()

func _init():
	_self = get_parent().get_parent()
	mesh = _self.get_node("Mesh")
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#
#func _input(event):
#	if event is InputEventMouseMotion:
#		_self.cam.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
#		_self.cam.rotation_degrees.x = clamp(_self.cam.rotation_degrees.x, -90, 90)
	

func move(delta):
#	var screen_pos = get_viewport().get_camera().unproject_position(_self.global_transform.origin)
#	var mouse_pos = get_viewport().get_mouse_position()
#	var angle = screen_pos.angle_to_point(mouse_pos)
#	_self.rotation.y = -angle 
	
#	velocity = Vector3()
	
	var motionTarget = Vector2 (Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right"),
							Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
	var moveAmount = motionTarget.length()
	
	var motion = motion.linear_interpolate(motionTarget * MOVE_SPEED, MOVEMENTINTERPOLATION * delta)
	
	#Gets the floor velocity
#	if _self.is_on_floor(): prevVelocity = _self.get_floor_velocity()
	
	#Adds the direction of the camera to the movement direction
	var cam_z = - _self.cam.global_transform.basis.z
	var cam_x = _self.cam.global_transform.basis.x
	cam_z.y = 0
	cam_z = cam_z.normalized()
	cam_x.y = 0
	cam_x = cam_x.normalized()
	
	var direction = - cam_x * motion.x -  cam_z * motion.y
	velocity.x = direction.x
	velocity.z = direction.z
	
	if motionTarget.length() > 0.01:
		#Rotates the charcter to the direction movement
		rotateCharacter(direction, delta)
	
	var grounded = _self.is_on_floor()
	velocity.y -= GRAVITY
	
	var just_jumped = false
	
	if Input.is_action_just_pressed("jump"):
		print_debug(grounded)
		just_jumped = true
		velocity.y = JUMP_FORCE
	
	if Input.is_action_just_pressed("change_camera"):
		print_debug(velocity)
	
#	if grounded and velocity.y <= 0:
#		velocity.y = -0.1
#	if velocity.y < -MAX_FALL_SPEED:
#		velocity.y = -MAX_FALL_SPEED
	
#	velocity = velocity.normalized()
	velocity = _self.move_and_slide(velocity)
	
	
	
func rotateCharacter(direction, delta):
	var q_from = Quat(orientation.basis)
	var q_to = Quat(Transform().looking_at(direction, Vector3.UP).basis)
	#Interpolate current rotation with desired one
	orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATIONINTERPOLATION))
	orientation = orientation.orthonormalized() # orthonormalize orientation
	mesh.global_transform.basis = orientation.basis 
