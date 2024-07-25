extends CharacterBody2D


@export var device_num = 0
var player_name = 'player'
var type = "player"
var deadzone = 0.1
const SPEED = 70.0
var keyboard = false
var free_cam = false
var MAX_ZOOM = Vector2(8,8)
var MIN_ZOOM = Vector2(3, 3)
const ZOOM_SPEED = 0.1
var in_build_menu = false
var in_placement_mode = false #this will allow you to be in a free cam mode to place the tower centered on camera
var resources: int = 100
var owned_towers = []
var disconnected = false
var health = 10
@export var damage = 1

var BuildMenu = load(GamePaths.BuildMenu)
var buildmenu = BuildMenu.instantiate()

@onready var animation_tree : AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true
	$running_attack_sword.hide()
	$attack_box.hide()
	$death_sprite.hide()

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
	if not free_cam and health > 0:
		velocity = movement()
	elif health <= 0:
		velocity = Vector2.ZERO
	move_and_slide()


func animation_manager():
		if health <= 0:
			is_dead()
			animation_tree["parameters/conditions/dead"] = true
		else:
			if velocity == Vector2.ZERO:
				animation_tree["parameters/conditions/idle"] = true
				animation_tree["parameters/conditions/is_moving"] = false
				if !animation_tree["parameters/conditions/attack"]:
					is_idle()
			else:
				animation_tree["parameters/conditions/idle"] = false
				animation_tree["parameters/conditions/is_moving"] = true
				if !animation_tree["parameters/conditions/attack"]:
					is_moving()
				$attack_box.rotation = calculate_vector_degree()
				animation_tree["parameters/Idle/blend_position"] = velocity
				animation_tree["parameters/Running/blend_position"] = velocity
				animation_tree["parameters/Attack/blend_position"] = velocity
			if Input.is_action_just_pressed("R_Trigger_action{n}".format({"n":device_num})):
				# do attack Right hand
				animation_tree["parameters/conditions/attack"] = true
				$attack_box.monitoring = true
				await get_tree().create_timer(0.4).timeout
				$attack_box.monitoring = false


func calculate_vector_degree():
	var angle = ((velocity / SPEED).angle()) - (PI / 2) #aka 90 degrees
	return angle

func is_not_attacking():
	animation_tree["parameters/conditions/attack"] = false
	$running_attack_sword.hide()

func is_attacking():
	$no_weapon_sprite_idle.hide()
	$no_weapon_sprite_running.hide()
	$running_attack_sword.show()

func is_moving():
	$no_weapon_sprite_idle.hide()
	$no_weapon_sprite_running.show()

func is_idle():
	$no_weapon_sprite_idle.show()
	$no_weapon_sprite_running.hide()

func is_dead():
	$death_sprite.show()
	$no_weapon_sprite_idle.hide()
	$no_weapon_sprite_running.hide()
	$running_attack_sword.hide()

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

	if event.is_action_pressed("L_Trigger_action{n}".format({"n":device_num})):
		# do attack Left hand
		pass


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

func zoom_process():
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


func _process(_delta):
	animation_manager()
	zoom_process()
	if free_cam or in_placement_mode:
		move_camera()
	else:
		SplitScreenFunctionality.player_characters[device_num]["camera"].position = self.position


func _on_attack_box_body_entered(body):
	print(body)
	if body in get_tree().get_nodes_in_group("enemy"):
		body.health -= damage
