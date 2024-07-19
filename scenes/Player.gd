extends CharacterBody2D


@export var device_num = 0
var player_name = 'player'
var deadzone = 0.1
const SPEED = 300.0
var keyboard = false
var free_cam = false
var MAX_ZOOM = Vector2(5,5)
var MIN_ZOOM = Vector2(0.25, 0.25)
const ZOOM_SPEED = 0.1
var in_build_menu = false
var in_placement_mode = false #this will allow you to be in a free cam mode to place the tower centered on camera
var resources: int = 10000
var owned_towers = []

var BuildMenu = load(GamePaths.BuildMenu)
var buildmenu = BuildMenu.instantiate()


#func _ready():
	#SplitScreenFunctionality.player_characters[device_num]["viewport"].add_child(buildmenu)
	#SplitScreenFunctionality.player_characters[device_num]["viewport"].get_node(buildmenu).hide()


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
	# include rotation if we deem necessary


func _physics_process(_delta):
	if not free_cam:
		velocity = movement()
		
		#animation direction
		if velocity == Vector2.ZERO:
			pass #maintains dirtection when holding still
		else:
			$AnimationTree.set("parameters/BlendSpace2D/blend_position", velocity)
	move_and_slide()


func _input(event):
	#this will error until I find key for it but on keyboard as its for controller currently
	if event.is_action_released("D_DOWN_action{n}".format({"n":device_num})):
		# toggle free camera mode
		free_cam = !free_cam
		velocity = Vector2.ZERO
		if free_cam:
			print("Player {n} entered freecam".format({"n": device_num}))
		else:
			print("Player {n} exited freecam".format({"n": device_num}))

	# Open X Craft Menu
	if event.is_action_pressed("LEFT_action{n}".format({"n":device_num})) and !in_placement_mode:
		toggle_build_menu()
		
	#print(event)
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			#print("scrolling")


func toggle_build_menu():
		if !in_build_menu:
			in_build_menu = !in_build_menu
			print("Opening Crafting Menu")
			buildmenu.Btype = "LEFT"
			buildmenu.player = self
			SplitScreenFunctionality.player_characters[device_num]["viewport"].add_child(buildmenu)
			#SplitScreenFunctionality.player_characters[device_num]["viewport"].get_node(buildmenu).show()
		else:
			in_build_menu = !in_build_menu
			buildmenu.Btype = null
			SplitScreenFunctionality.player_characters[device_num]["viewport"].remove_child(buildmenu)
			#SplitScreenFunctionality.player_characters[device_num]["viewport"].get_node(buildmenu).hide()
			print("Closing Crafting Menu")


func _process(_delta):
	
	if keyboard: #keybboard zoom
		if Input.is_action_just_pressed("R_Shoulder_action{n}".format({"n":device_num})):
			var zoom_check = Vector2(SplitScreenFunctionality.player_characters[device_num]["camera"].zoom.x + ZOOM_SPEED,SplitScreenFunctionality.player_characters[device_num]["camera"].zoom.y + ZOOM_SPEED)
			if zoom_check < MAX_ZOOM and zoom_check > MIN_ZOOM:
				SplitScreenFunctionality.player_characters[device_num]["camera"].zoom = zoom_check
		if Input.is_action_just_pressed("L_Shoulder_action{n}".format({"n":device_num})):
			var zoom_check = Vector2(SplitScreenFunctionality.player_characters[device_num]["camera"].zoom.x - ZOOM_SPEED,SplitScreenFunctionality.player_characters[device_num]["camera"].zoom.y - ZOOM_SPEED)
			if zoom_check < MAX_ZOOM and zoom_check > MIN_ZOOM:
				SplitScreenFunctionality.player_characters[device_num]["camera"].zoom = zoom_check
	else:	#gamepad zoom bumpers
		if Input.is_action_pressed("R_Shoulder_action{n}".format({"n":device_num})):
			var zoom_check = Vector2(SplitScreenFunctionality.player_characters[device_num]["camera"].zoom.x + ZOOM_SPEED,SplitScreenFunctionality.player_characters[device_num]["camera"].zoom.y + ZOOM_SPEED)
			if zoom_check < MAX_ZOOM and zoom_check > MIN_ZOOM:
				SplitScreenFunctionality.player_characters[device_num]["camera"].zoom = zoom_check
		if Input.is_action_pressed("L_Shoulder_action{n}".format({"n":device_num})):
			var zoom_check = Vector2(SplitScreenFunctionality.player_characters[device_num]["camera"].zoom.x - ZOOM_SPEED,SplitScreenFunctionality.player_characters[device_num]["camera"].zoom.y - ZOOM_SPEED)
			if zoom_check < MAX_ZOOM and zoom_check > MIN_ZOOM:
				SplitScreenFunctionality.player_characters[device_num]["camera"].zoom = zoom_check


	if free_cam or in_placement_mode:
		move_camera()
	else:
		SplitScreenFunctionality.player_characters[device_num]["camera"].position = self.position

