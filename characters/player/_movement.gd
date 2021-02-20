extends Node


export var gravity = Vector3.DOWN * 10
export var speed = 4
export var rot_speed = 0.85

var body
var velocity = Vector3.ZERO

func move(delta):
	body = get_parent().get_parent()
	velocity += gravity * delta
	get_input(delta)
	velocity = body.move_and_slide(velocity, Vector3.UP)
	
	
func get_input(delta):
	var vy = velocity.y
	velocity = Vector3.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity += -body.transform.basis.z * speed
	if Input.is_action_pressed("ui_down"):
		velocity += body.transform.basis.z * speed
	if Input.is_action_pressed("ui_right"):
		body.rotate_y(-rot_speed * delta)
	if Input.is_action_pressed("ui_left"):
		body.rotate_y(rot_speed * delta)
	velocity.y = vy
