extends CharacterBody2D

@export var device_num = 0
var player_name = 'player'
var deadzone = 0.1
const SPEED = 300.0
var keyboard = false

func movement():
	# produces velocity by returning Vector2D
	var input_direction
	if keyboard:
		input_direction = Input.get_vector(	"ui_leftK{n}".format({"n":device_num}),
											"ui_rightK{n}".format({"n":device_num}),
											"ui_upK{n}".format({"n":device_num}),
											"ui_downK{n}".format({"n":device_num})
											)
	else:
		input_direction = Input.get_vector(	"ui_left{n}".format({"n":device_num}),
											"ui_right{n}".format({"n":device_num}),
											"ui_up{n}".format({"n":device_num}),
											"ui_down{n}".format({"n":device_num})
											)
	velocity = input_direction * SPEED
	return velocity


func camera_toggle():
	pass


func _physics_process(delta):
	movement()
	move_and_slide()
