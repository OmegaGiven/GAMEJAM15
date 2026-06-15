extends CharacterBody2D

const PLAYER_COLORS = [
	Color(0.3, 0.55, 1.0),    # P1 blue
	Color(1.0, 0.28, 0.28),   # P2 red
	Color(0.25, 1.0, 0.4),    # P3 green
	Color(1.0, 0.85, 0.1),    # P4 yellow
]

@export var device_num = 0
var player_name = 'player'
var type = "player"
var player_color: Color = Color.WHITE
var deadzone = 0.1
const _BASE_SPEED = 70.0
var keyboard = false
var free_cam = false
var MAX_ZOOM = Vector2(8,8)
var MIN_ZOOM = Vector2(3, 3)
const ZOOM_SPEED = 0.1
var in_build_menu = false
var in_placement_mode = false #this will allow you to be in a free cam mode to place the tower centered on camera
var resources: int
var owned_towers = []
var disconnected = false
var health = 10
@export var damage = 10
var SPEED = 70.0

var reaper_power_active = false
var reaper_power_timer = 0.0
const REAPER_POWER_DURATION = 30.0

var water_energy: float = 0.0
var earth_energy: float = 0.0

const CRAFT_TIME = 5.0
const MAX_TOTEMS_PER_TYPE = 10
var crafting_queues: Dictionary = {}  # {build_type: {count: int, timer: float}}
var inventory: Dictionary = {}        # {build_type: count}
var placed_totems: Dictionary = {}    # {build_type: count}

func start_craft(build_type: String, wood: int, water: float = 0.0, earth: float = 0.0) -> bool:
	if resources < wood:
		print("Player %d: need %d wood, have %d" % [device_num, wood, resources])
		return false
	if water > 0.0 and water_energy < water:
		print("Player %d: need %.0f water, have %.0f" % [device_num, water, water_energy])
		return false
	if earth > 0.0 and earth_energy < earth:
		print("Player %d: need %.0f earth, have %.0f" % [device_num, earth, earth_energy])
		return false
	resources -= wood
	water_energy -= water
	earth_energy -= earth
	if build_type in crafting_queues:
		crafting_queues[build_type]["count"] += 1
		print("Player %d: queued %s (%d in queue)" % [device_num, build_type, crafting_queues[build_type]["count"]])
	else:
		crafting_queues[build_type] = {"count": 1, "timer": CRAFT_TIME}
		print("Player %d: crafting %s..." % [device_num, build_type])
	return true

func consume_inventory(build_type: String) -> bool:
	if inventory.get(build_type, 0) <= 0:
		return false
	inventory[build_type] -= 1
	return true

func can_place_totem(build_type: String) -> bool:
	return placed_totems.get(build_type, 0) < MAX_TOTEMS_PER_TYPE

func on_totem_placed(build_type: String):
	placed_totems[build_type] = placed_totems.get(build_type, 0) + 1

func on_totem_removed(build_type: String):
	placed_totems[build_type] = max(0, placed_totems.get(build_type, 0) - 1)

func _tick_crafting(delta: float):
	var to_remove: Array = []
	for build_type in crafting_queues:
		var q = crafting_queues[build_type]
		q["timer"] -= delta
		if q["timer"] <= 0.0:
			inventory[build_type] = inventory.get(build_type, 0) + 1
			q["count"] -= 1
			if q["count"] > 0:
				q["timer"] = CRAFT_TIME
				print("Player %d: %s ready! (%d more in queue)" % [device_num, build_type, q["count"]])
			else:
				to_remove.append(build_type)
				print("Player %d: %s ready!" % [device_num, build_type])
	for build_type in to_remove:
		crafting_queues.erase(build_type)

func add_elemental_energy(element: String, amount: float):
	match element:
		"water":
			water_energy += amount
			print("Player %d water energy: %.1f" % [device_num, water_energy])
		"earth":
			earth_energy += amount
			print("Player %d earth energy: %.1f" % [device_num, earth_energy])

var BuildMenu = load(GamePaths.BuildMenu)
var buildmenu = BuildMenu.instantiate()

@onready var animation_tree : AnimationTree = $AnimationTree

func _ready():
	resources = Settings.starting_resources
	player_color = PLAYER_COLORS[device_num % PLAYER_COLORS.size()]
	animation_tree.active = true
	$running_attack_sword.hide()
	$attack_box.hide()
	$death_sprite.hide()
	add_to_group("player")

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


func activate_reaper_power():
	reaper_power_active = true
	reaper_power_timer = REAPER_POWER_DURATION
	damage = 30
	SPEED = _BASE_SPEED * 2.0
	print("Player %d: REAPER POWER ACTIVATED (%.0fs)" % [device_num, REAPER_POWER_DURATION])

func deactivate_reaper_power():
	reaper_power_active = false
	damage = 10
	SPEED = _BASE_SPEED
	print("Player %d: Reaper Power ended" % device_num)

func _process(delta):
	if reaper_power_active:
		reaper_power_timer -= delta
		if reaper_power_timer <= 0:
			deactivate_reaper_power()
	_tick_crafting(delta)
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
	if body.type == "player" and body != self:
		body.health -= damage
	if body.type == "base":
		if resources > 0:
			if resources > 10:
				body.health += 10
				resources -= 10
			else:
				body.health += resources
				resources -= resources
	if body.type == "resource":
		body.health -= damage
		resources += damage
