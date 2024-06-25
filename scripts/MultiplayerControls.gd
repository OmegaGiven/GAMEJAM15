extends Node
#
#signal connected
#signal disconnected

var num_players = Input.get_connected_joypads().size()
var players: Array = []
var input_maps: Array = []
var keyboard: bool = false # For keyboard use

func _ready():
	print("Number of Controllers Connected: ", num_players)
	
	# Connect to the signal that detects when a joystick connects
	var _new_connection: int
	_new_connection = Input.joy_connection_changed.connect(_on_joy_connection_changed)
	#if _new_connection != 0:
		#print("Error {e} connecting `Input` signal `joy_connection_changed`.".format({"e": _new_connection}))
	#else:
		#print("No player connected")

func _on_joy_connection_changed(device: int, connected: bool):
	if connected:
		# Update number of players to number of connected joysticks.
		num_players = Input.get_connected_joypads().size()
		print("Connected device {d}.".format({"d":device}))
		# Add the player to the world as device number for  player index into the array of players.
		add_player(device)
		print("Added player index {d} to the world.".format({"d":device}))
		print(players)
	else:
		# Do not change the number of players when a player disconnects.
		remove_player(device)
		print("Removed player index {d} from the world.".format({"d":device}))
		print("Disconnected device {d}.".format({"d":device}))

func remove_player(player_index: int) -> void:
	# TODO: Remove the player. Or show in some way that the
	# player is inactive.
	# For now I leave the disconnected player on screen and
	# do nothing. The player is technically still "in play" and
	# other players can interact with it. But the player cannot
	# be controlled because the joystick is disconnected.
	# When the joystick reconnects, control is restored.
	emit_signal("disconnected", players[player_index].player_name)
	print("Player Removed: ", players[player_index].player_name)

func add_player(player_index: int) -> void:
	# `player_index` is the player array `players` also their joystick number
	
	#for if a player disconnects and reconnect controller they keep their player number
	if player_index < players.size():
		# TODO: add code to revive old player.
		# I'll need to "revive" once I've coded "removal."
		# For now I leave the disconnected player on screen and
		# do nothing, so there is nothing to do to "revive" the
		# player. They reconnect their joystick and they can move
		# again.
		emit_signal("connected", players[player_index].player_name)
		print("Player added: ", players[player_index].player_name)
		return
	
	# Instantiate a new player and appends to players list
	var Player = load("res://scenes/Player.tscn")
	var player = Player.instantiate()
	#get_tree().get_first_node_in_group("World").add_child(player)
	players.append(player)

	# Create an input_map dict for this player's joystick/keyboard.
	input_maps.append({
		"ui_right{n}".format({"n":player_index}): Vector2.RIGHT,
		"ui_left{n}".format({"n":player_index}): Vector2.LEFT,
		"ui_up{n}".format({"n":player_index}): Vector2.UP,
		"ui_down{n}".format({"n":player_index}): Vector2.DOWN,
		
		"ui_rightR{n}".format({"n":player_index}): Vector2.RIGHT,
		"ui_leftR{n}".format({"n":player_index}): Vector2.LEFT,
		"ui_upR{n}".format({"n":player_index}): Vector2.UP,
		"ui_downR{n}".format({"n":player_index}): Vector2.DOWN,
		
		"RIGHT_action{n}".format({"n":player_index}): JOY_BUTTON_B,
		"BOTTOM_action{n}".format({"n":player_index}): JOY_BUTTON_A,
		"LEFT_action{n}".format({"n":player_index}): JOY_BUTTON_X,
		"TOP_action{n}".format({"n":player_index}): JOY_BUTTON_Y,
		
		"menu_action{n}".format({"n":player_index}): JOY_BUTTON_START,
		"back_action{n}".format({"n":player_index}): JOY_BUTTON_BACK,
		
		"D_LEFT_action{n}".format({"n":player_index}): JOY_BUTTON_DPAD_LEFT,
		"D_RIGHT_action{n}".format({"n":player_index}):JOY_BUTTON_DPAD_RIGHT,
		"D_UP_action{n}".format({"n":player_index}): JOY_BUTTON_DPAD_UP, 
		"D_DOWN_action{n}".format({"n":player_index}): JOY_BUTTON_DPAD_DOWN, 
		
		"R_Trigger_action{n}".format({"n":player_index}): JOY_AXIS_TRIGGER_RIGHT,
		"L_Trigger_action{n}".format({"n":player_index}): JOY_AXIS_TRIGGER_LEFT,

		"R_Shoulder_action{n}".format({"n":player_index}): JOY_BUTTON_RIGHT_SHOULDER,
		"L_Shoulder_action{n}".format({"n":player_index}): JOY_BUTTON_LEFT_SHOULDER,
		})
	print("Input Map: ", input_maps[player_index])
	
	# Assign the input_map to this player.
	player.ui_inputs = input_maps[player_index]

	if not keyboard:
		# Assign the joystick device number to this player.
		player.device_num = player_index

		# Edit the InputMap to match the names used in the input_map assignments.
		# For example, default InputMap has name "ui_left".
		# I use the same default names but with a device number suffix.
		# So "ui_left" becomes "ui_left0", "ui_left1", etc.
		# These are called "actions". The joypad motion that triggers
		# the action is called an "action event".

		#
		#  Left Joy Stick
		#  see this for GODOT supported Inputs https://docs.godotengine.org/en/4.2/classes/class_@globalscope.html
		var right_action: String
		var right_action_event: InputEventJoypadMotion
		right_action = "ui_right{n}".format({"n":player_index})
		InputMap.add_action(right_action)
		right_action_event = InputEventJoypadMotion.new()
		right_action_event.device = player_index
		right_action_event.axis = JOY_AXIS_LEFT_X # <---- horizontal axis
		right_action_event.axis_value =  1.0 # <---- right
		InputMap.action_add_event(right_action, right_action_event)
		InputMap.action_add_event("ui_right", right_action_event)

		var left_action: String
		var left_action_event: InputEventJoypadMotion
		left_action = "ui_left{n}".format({"n":player_index})
		InputMap.add_action(left_action)
		left_action_event = InputEventJoypadMotion.new()
		left_action_event.device = player_index
		left_action_event.axis = JOY_AXIS_LEFT_X # <---- horizontal axis
		left_action_event.axis_value = -1.0 # <---- left
		InputMap.action_add_event(left_action, left_action_event)
		InputMap.action_add_event("ui_left", left_action_event)

		var up_action: String
		var up_action_event: InputEventJoypadMotion
		up_action = "ui_up{n}".format({"n":player_index})
		InputMap.add_action(up_action)
		up_action_event = InputEventJoypadMotion.new()
		up_action_event.device = player_index
		up_action_event.axis = JOY_AXIS_LEFT_Y # <---- vertical axis
		up_action_event.axis_value = -1.0 # <---- up
		InputMap.action_add_event(up_action, up_action_event)
		InputMap.action_add_event("ui_up", up_action_event)

		var down_action: String
		var down_action_event: InputEventJoypadMotion
		down_action = "ui_down{n}".format({"n":player_index})
		InputMap.add_action(down_action)
		down_action_event = InputEventJoypadMotion.new()
		down_action_event.device = player_index
		down_action_event.axis = JOY_AXIS_LEFT_Y # <---- vertical axis
		down_action_event.axis_value =  1.0 # <---- down
		InputMap.action_add_event(down_action, down_action_event)
		InputMap.action_add_event("ui_down", down_action_event)

		#
		#  Right Joy Stick
		#
		var R_Stick_right_action: String
		var R_Stick_right_action_event: InputEventJoypadMotion
		#see this for GODOT supported Inputs https://docs.godotengine.org/en/4.2/classes/class_@globalscope.html
		R_Stick_right_action = "ui_rightR{n}".format({"n":player_index})
		InputMap.add_action(R_Stick_right_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		R_Stick_right_action_event = InputEventJoypadMotion.new()
		R_Stick_right_action_event.device = player_index
		R_Stick_right_action_event.axis = JOY_AXIS_RIGHT_X # <---- horizontal axis
		R_Stick_right_action_event.axis_value =  1.0 # <---- right
		InputMap.action_add_event(R_Stick_right_action, R_Stick_right_action_event)

		var R_Stick_left_action: String
		var R_Stick_left_action_event: InputEventJoypadMotion
		R_Stick_left_action = "ui_leftR{n}".format({"n":player_index})
		InputMap.add_action(R_Stick_left_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		R_Stick_left_action_event = InputEventJoypadMotion.new()
		R_Stick_left_action_event.device = player_index
		R_Stick_left_action_event.axis = JOY_AXIS_RIGHT_X # <---- horizontal axis
		R_Stick_left_action_event.axis_value = -1.0 # <---- left
		InputMap.action_add_event(R_Stick_left_action, R_Stick_left_action_event)

		var R_Stick_up_action: String
		var R_Stick_up_action_event: InputEventJoypadMotion
		R_Stick_up_action = "ui_upR{n}".format({"n":player_index})
		InputMap.add_action(R_Stick_up_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		R_Stick_up_action_event = InputEventJoypadMotion.new()
		R_Stick_up_action_event.device = player_index
		R_Stick_up_action_event.axis = JOY_AXIS_RIGHT_Y # <---- vertical axis
		R_Stick_up_action_event.axis_value = -1.0 # <---- up
		InputMap.action_add_event(R_Stick_up_action, R_Stick_up_action_event)

		var R_Stick_down_action: String
		var R_Stick_down_action_event: InputEventJoypadMotion
		R_Stick_down_action = "ui_downR{n}".format({"n":player_index})
		InputMap.add_action(R_Stick_down_action)
		# Creat a new InputEvent instance to assign to the InputMap.
		R_Stick_down_action_event = InputEventJoypadMotion.new()
		R_Stick_down_action_event.device = player_index
		R_Stick_down_action_event.axis = JOY_AXIS_RIGHT_Y # <---- vertical axis
		R_Stick_down_action_event.axis_value =  1.0 # <---- down
		InputMap.action_add_event(R_Stick_down_action, R_Stick_down_action_event)

		#
		# Right BUTTONS on CONTROLLER
		#
		var jump_action: String
		var jump_action_event: InputEventJoypadButton
		jump_action = "RIGHT_action{n}".format({"n":player_index})
		InputMap.add_action(jump_action)
		jump_action_event = InputEventJoypadButton.new()
		jump_action_event.device = player_index
		jump_action_event.button_index = JOY_BUTTON_B
		InputMap.action_add_event(jump_action, jump_action_event)
		
		var select_action: String
		var select_action_event: InputEventJoypadButton
		select_action = "BOTTOM_action{n}".format({"n":player_index})
		InputMap.add_action(select_action)
		select_action_event = InputEventJoypadButton.new()
		select_action_event.device = player_index
		select_action_event.button_index = JOY_BUTTON_A
		InputMap.action_add_event("ui_accept", select_action_event)
		InputMap.action_add_event(select_action, select_action_event)
		
		var top_button_action: String
		var top_button_event: InputEventJoypadButton
		top_button_action = "TOP_action{n}".format({"n":player_index})
		InputMap.add_action(top_button_action)
		top_button_event = InputEventJoypadButton.new()
		top_button_event.device = player_index
		top_button_event.button_index = JOY_BUTTON_BACK
		InputMap.action_add_event(top_button_action, top_button_event)

		var left_button_action: String
		var left_button_event: InputEventJoypadButton
		left_button_action = "LEFT_action{n}".format({"n":player_index})
		InputMap.add_action(left_button_action)
		left_button_event = InputEventJoypadButton.new()
		left_button_event.device = player_index
		left_button_event.button_index = JOY_BUTTON_X
		InputMap.action_add_event(left_button_action, left_button_event)


		var menu_action: String
		var menu_action_event: InputEventJoypadButton
		menu_action = "menu_action{n}".format({"n":player_index})
		InputMap.add_action(menu_action)
		menu_action_event = InputEventJoypadButton.new()
		menu_action_event.device = player_index
		menu_action_event.button_index = JOY_BUTTON_START
		InputMap.action_add_event(menu_action, menu_action_event)

		var back_action: String
		var back_action_event: InputEventJoypadButton
		back_action = "back_action{n}".format({"n":player_index})
		InputMap.add_action(back_action)
		back_action_event = InputEventJoypadButton.new()
		back_action_event.device = player_index
		back_action_event.button_index = JOY_BUTTON_BACK
		InputMap.action_add_event(back_action, back_action_event)

		#
		#  D PAD
		#
		var D_Left_action: String
		var D_Left_event: InputEventJoypadButton
		D_Left_action = "D_Left_action{n}".format({"n":player_index})
		InputMap.add_action(D_Left_action)
		D_Left_event = InputEventJoypadButton.new()
		D_Left_event.device = player_index
		D_Left_event.button_index = JOY_BUTTON_DPAD_LEFT
		InputMap.action_add_event(D_Left_action, D_Left_event)
		
		var D_Right_action: String
		var D_Right_event: InputEventJoypadButton
		D_Right_action = "D_Right_action{n}".format({"n":player_index})
		InputMap.add_action(D_Right_action)
		D_Right_event = InputEventJoypadButton.new()
		D_Right_event.device = player_index
		D_Right_event.button_index = JOY_BUTTON_DPAD_RIGHT
		InputMap.action_add_event(D_Right_action, D_Right_event)
		
		var D_UP_action: String
		var D_UP_event: InputEventJoypadButton
		D_UP_action = "D_UP_action{n}".format({"n":player_index})
		InputMap.add_action(D_UP_action)
		D_UP_event = InputEventJoypadButton.new()
		D_UP_event.device = player_index
		D_UP_event.button_index = JOY_BUTTON_DPAD_UP
		InputMap.action_add_event(D_UP_action, D_UP_event)
		
		var D_Down_action: String
		var D_Down_event: InputEventJoypadButton
		D_Down_action = "D_Down_action{n}".format({"n":player_index})
		InputMap.add_action(D_Down_action)
		D_Down_event = InputEventJoypadButton.new()
		D_Down_event.device = player_index
		D_Down_event.button_index = JOY_BUTTON_DPAD_DOWN
		InputMap.action_add_event(D_Down_action, D_Down_event)

		#
		# Trigger buttons
		#
		var R_Trigger_action: String
		var R_Trigger_event: InputEventJoypadMotion
		R_Trigger_action = "R_Trigger_action{n}".format({"n":player_index})
		InputMap.add_action(R_Trigger_action)
		R_Trigger_event = InputEventJoypadMotion.new()
		R_Trigger_event.device = player_index
		R_Trigger_event.axis = JOY_AXIS_TRIGGER_RIGHT
		R_Trigger_event.axis_value = 1
		InputMap.action_add_event(R_Trigger_action, R_Trigger_event)
		
		var L_Trigger_action: String
		var L_Trigger_event: InputEventJoypadMotion
		L_Trigger_action = "L_Trigger_action{n}".format({"n":player_index})
		InputMap.add_action(L_Trigger_action)
		L_Trigger_event = InputEventJoypadMotion.new()
		L_Trigger_event.device = player_index
		L_Trigger_event.axis = JOY_AXIS_TRIGGER_LEFT
		L_Trigger_event.axis_value = 1
		InputMap.action_add_event(L_Trigger_action, L_Trigger_event)
		
		#
		# Bumper buttons
		#
		var R_Shoulder_action: String
		var R_Shoulder_event: InputEventJoypadButton
		R_Shoulder_action = "R_Shoulder_action{n}".format({"n":player_index})
		InputMap.add_action(R_Shoulder_action)
		R_Shoulder_event = InputEventJoypadButton.new()
		R_Shoulder_event.device = player_index
		R_Shoulder_event.button_index = JOY_BUTTON_RIGHT_SHOULDER
		InputMap.action_add_event(R_Shoulder_action, R_Shoulder_event)
		
		var L_Shoulder_action: String
		var L_Shoulder_event: InputEventJoypadButton
		L_Shoulder_action = "L_Shoulder_action{n}".format({"n":player_index})
		InputMap.add_action(L_Shoulder_action)
		L_Shoulder_event = InputEventJoypadButton.new()
		L_Shoulder_event.device = player_index
		L_Shoulder_event.button_index = JOY_BUTTON_LEFT_SHOULDER
		InputMap.action_add_event(L_Shoulder_action, L_Shoulder_event)

	else:
		# Use keyboard
		var arrows: Dictionary = {
			"key_right": KEY_RIGHT,
			"key_left":  KEY_LEFT,
			"key_up":    KEY_UP,
			"key_down":  KEY_DOWN,
			}
		var wasd: Dictionary = {
			"key_right": KEY_D,
			"key_left":  KEY_A,
			"key_up":    KEY_W,
			"key_down":  KEY_S,
			}
		var keymaps: Dictionary = {
			0: arrows,
			1: wasd,
			}

		var right_action: String
		var right_action_event: InputEventKey
		right_action = "ui_right{n}".format({"n":player_index})
		InputMap.add_action(right_action)
		right_action_event = InputEventKey.new()
		right_action_event.keycode = keymaps[player_index]["key_right"]
		InputMap.action_add_event(right_action, right_action_event)

		var left_action: String
		var left_action_event: InputEventKey
		left_action = "ui_left{n}".format({"n":player_index})
		InputMap.add_action(left_action)
		left_action_event = InputEventKey.new()
		left_action_event.keycode = keymaps[player_index]["key_left"]
		InputMap.action_add_event(left_action, left_action_event)

		var up_action: String
		var up_action_event: InputEventKey
		up_action = "ui_up{n}".format({"n":player_index})
		InputMap.add_action(up_action)
		up_action_event = InputEventKey.new()
		up_action_event.keycode = keymaps[player_index]["key_up"]
		InputMap.action_add_event(up_action, up_action_event)

		var down_action: String
		var down_action_event: InputEventKey
		down_action = "ui_down{n}".format({"n":player_index})
		InputMap.add_action(down_action)
		down_action_event = InputEventKey.new()
		down_action_event.keycode = keymaps[player_index]["key_down"]
		InputMap.action_add_event(down_action, down_action_event)
