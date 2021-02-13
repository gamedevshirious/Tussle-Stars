extends Node

const MOVE_SPEED = 12
const JUMP_FORCE = 50
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30

var y_velo = 0
var current_facing = 0

func move(_self, delta):
	_self = get_parent().get_parent()
	var move_vec = Vector3()
	if Input.is_action_pressed("ui_left"):
#		move_vec.z -= 1
		_self.rotate_object_local(Vector3(0, 1, 0), .1)
#		_self.get_node("Mesh").rotation_degrees.y = clamp(_self.get_node("Mesh").rotation_degrees.y, current_facing, 90)
	if Input.is_action_pressed("ui_right"):
#		move_vec.z += 1
		_self.rotate_object_local(Vector3(0, 1, 0), -.1)
		
#		_self.get_node("Mesh").rotation_degrees.y = clamp(_self.get_node("Mesh").rotation_degrees.y, -90, current_facing)
	if Input.is_action_pressed("ui_up"):
		move_vec.x += 1
#		_self.translate_object_local(_self.transform.basis.x)
#		if _self.get_node("Mesh").rotation_degrees.y < 0:
#			_self.get_node("Mesh").rotation_degrees.y += 5
#			_self.get_node("Mesh").rotation_degrees.y = clamp(_self.get_node("Mesh").rotation_degrees.y, 0, current_facing)
#		else:
#			_self.get_node("Mesh").rotation_degrees.y -= 5
#			_self.get_node("Mesh").rotation_degrees.y = clamp(_self.get_node("Mesh").rotation_degrees.y, current_facing, 0)

			
		
#		_self.get_node("Mesh").rotation_degrees.y = lerp_angle(90, _self.rotation_degrees.y, .01)
	if Input.is_action_pressed("ui_down"):
		move_vec.x -= 1
#		_self.translate_object_local(-_self.transform.basis.x)
	# _self.get_node("Mesh").rotation_degrees.y = lerp_angle(_self.get_node("Mesh").rotation_degrees.y, 0, .1)
#	if _self.cam.name == "TPCamera":
#	_self.get_node("Mesh").rotation.y = lerp_angle(_self.get_node("Mesh").rotation.y , 0, 45 * delta * .1)
#	else:
#		_self.rotation_degrees.y = _self.get_node("Mesh").rotation_degrees.y
#		_self.get_node("Mesh").rotation_degrees.y = 0
	current_facing = _self.get_node("Mesh").rotation_degrees.y
#	move_vec.z -= Input.get_action_strength("ui_up")
#	move_vec.z += Input.get_action_strength("ui_down") / 2 
#	move_vec.x += Input.get_action_strength("ui_right")
#	move_vec.x -= Input.get_action_strength("ui_left")


	var grounded = _self.is_on_floor()

	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), _self.rotation.y)
	move_vec *= MOVE_SPEED
	move_vec.y = y_velo
	
#	_self.get_node("Mesh/legs").rotation.y = move_vec.rotated(Vector3(0, 1, 0), _self.rotation.y).y
	
	move_vec = _self.move_and_slide(move_vec, Vector3(0, 1, 0))

	if abs(move_vec.length_squared()) > 1:
		if grounded:
			_self.get_node("AnimationTree").set("parameters/walk/add_amount",  1)
	else:
		_self.get_node("AnimationTree").set("parameters/walk/add_amount",  0)

	
	y_velo -= GRAVITY
	
	if grounded and Input.is_action_just_pressed("jump"):
		y_velo = JUMP_FORCE

	if grounded and y_velo <= 0:
		y_velo = -0.1
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED

#	if Input.is_action_just_pressed("focus"):
#		if _self.cam.name == "TPCamera":
#			if not _self.zoomed_in:
#				_self.cam.translation = Vector3(4, 4, 3)
#				_self.zoomed_in = true
#			else:
#				_self.cam.translation = Vector3(-5, 4, 0)
#				_self.zoomed_in = false
