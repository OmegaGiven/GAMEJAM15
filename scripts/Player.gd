extends CharacterBody2D

@export var device_num = 0
var player_name = 'player'
var deadzone = 0.1
const SPEED = 300.0
var keyboard = false
var free_cam = false

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


func move_camera():
	#TODO
	# get camera for player will setup global for this
	# turn vector movement to translate camera
	# include code to manipulate camera scale with right stick
	# include rotation if we deem necessary
	pass

func direction_manager():
	#TODO get animation direction and apply to player sprite
	pass



func _physics_process(_delta):
	if not free_cam:
		movement()
	move_and_slide()

func _input(event):
	#this will error until I find key for it but on keyboard as its for controller currently
	if event.is_action_released("D_DOWN_action{n}".format({"n":device_num})) :
		# toggle free camera mode
		free_cam = !free_cam
		print("Player {n} entered freecam".format({"n": device_num}))


func _process(_delta):
	
	#if camera mode
	# move camera()
	pass
