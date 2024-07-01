extends CharacterBody2D

@export var device_num = 0
var player_name = 'player'
var deadzone = 0.1
const SPEED = 300.0-+
var keyboard = false
var free_cam = false
var MAX_ZOOM = Vector2(5,5)
var MIN_ZOOM = Vector2(0.25, 0.25)
var ZOOM_SPEED = 0.1

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
	var v = input_direction * SPEED
	return v


func move_camera():
	SplitScreenFunctionality.player_characters[device_num]["camera"].position += movement() * .1
	# get camera for player will setup global for this
	# turn vector movement to translate camera
	# include code to manipulate camera scale with right stick
	# include rotation if we deem necessary

func direction_manager():
	#TODO get animation direction and apply to player sprite
	pass



func _physics_process(_delta):
	if not free_cam:
		velocity = movement()
	move_and_slide()

func _input(event):
	#this will error until I find key for it but on keyboard as its for controller currently
	if event.is_action_released("D_DOWN_action{n}".format({"n":device_num})):
		# toggle free camera mode
		free_cam = !free_cam
		if free_cam:
			print("Player {n} entered freecam".format({"n": device_num}))
		else:
			print("Player {n} exited freecam".format({"n": device_num}))
	
	## zoom Camera (this is glitchy as its only upon movement of joystick but not holding the joystick in position)
	#if event.is_action("ui_upR{n}".format({"n":device_num})) or event.is_action("ui_downR{n}".format({"n":device_num})):
		#var zoom = SplitScreenFunctionality.player_characters[device_num]["camera"].zoom - (Vector2(event.axis_value, event.axis_value) * 0.1)
		#if zoom < MAX_ZOOM and zoom > MIN_ZOOM:
			#SplitScreenFunctionality.player_characters[device_num]["camera"].zoom = zoom


func _process(_delta):
	if free_cam:
		move_camera()
	else:
		SplitScreenFunctionality.player_characters[device_num]["camera"].position = self.position

	# zoom Camera "smoothish"
	if Input.get_joy_axis(device_num, JOY_AXIS_RIGHT_Y) > deadzone or Input.get_joy_axis(device_num, JOY_AXIS_RIGHT_Y) < -deadzone:
		var zoom = Vector2(Input.get_joy_axis(device_num, JOY_AXIS_RIGHT_Y), Input.get_joy_axis(device_num, JOY_AXIS_RIGHT_Y))
		var zoom_check = SplitScreenFunctionality.player_characters[device_num]["camera"].zoom + (ZOOM_SPEED * zoom)
		if zoom_check < MAX_ZOOM and zoom_check > MIN_ZOOM:
			SplitScreenFunctionality.player_characters[device_num]["camera"].zoom = zoom_check

