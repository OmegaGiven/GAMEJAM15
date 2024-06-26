extends CharacterBody2D

@export var device_num = 0
var player_name = 'player'
var deadzone = 0.1
const SPEED = 300.0
var keyboard = false

var ui_inputs = {
	"ui_right"	: Vector2.RIGHT,
	"ui_left"	: Vector2.LEFT,
	"ui_up"		: Vector2.UP,
	"ui_down"	: Vector2.DOWN,
}

func movement():
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


func _physics_process(delta):
	movement()
	move_and_slide()
