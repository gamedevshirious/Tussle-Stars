extends Node

const MOVE_SPEED = 12
const JUMP_FORCE = 50
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30

var y_velo = 0

func move(_self):
	var move_vec = Vector3()
#	if Input.is_action_pressed("ui_up"):
#		move_vec.z -= 1
#	if Input.is_action_pressed("ui_down"):
#		move_vec.z += 1
#	if Input.is_action_pressed("ui_right"):
#		move_vec.x += 1
#	if Input.is_action_pressed("ui_left"):
#		move_vec.x -= 1

	move_vec.z -= Input.get_action_strength("ui_up")
	move_vec.z += Input.get_action_strength("ui_down")
	move_vec.x += Input.get_action_strength("ui_right")
	move_vec.x -= Input.get_action_strength("ui_left")


#	if abs(move_vec.z) > 1:
#		$AnimationTree.set("parameters/walk/add_amount",  move_vec.z/10)
#	else:
#		$AnimationTree.set("parameters/walk/add_amount",  0)

	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), _self.rotation.y)
	move_vec *= MOVE_SPEED
	move_vec.y = y_velo



	move_vec = _self.move_and_slide(move_vec, Vector3(0, 1, 0))

	var grounded = _self.is_on_floor()
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
		if _self.cam.name == "TPCamera":
			if not _self.zoomed_in:
				_self.cam.translation = Vector3(3, 4, 4)
				_self.zoomed_in = true
			else:
				_self.cam.translation = Vector3(0, 4, 8)
				_self.zoomed_in = false
