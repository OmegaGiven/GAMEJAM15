extends CanvasLayer

var player
var Btype

"""
"RIGHT_action{n}".format({"n":player_index}): JOY_BUTTON_B,
"BOTTOM_action{n}".format({"n":player_index}): JOY_BUTTON_A,
"LEFT_action{n}".format({"n":player_index}): JOY_BUTTON_X,
"TOP_action{n}".format({"n":player_index}): JOY_BUTTON_Y,
"""

var current_tower

func _input(event):
	if player.in_placement_mode:
		if event.is_action_pressed("RIGHT_action{n}".format({"n":player.device_num})):
			player.in_placement_mode = false
			player.free_cam = false
			print("Canceling placement")
			if current_tower.in_placement:
				get_tree().get_first_node_in_group("LEVELS").remove_child(current_tower)
			player.toggle_build_menu()
		
	
	elif Btype == "LEFT":
		# will need to implement a resource check on the player that opened the build menu
		if event.is_action_pressed("BOTTOM_action{n}".format({"n":player.device_num})) or event.is_action_pressed("left_mouse_click"):
			$"Left Button Menu".hide()
			player.in_placement_mode = true
			player.free_cam = true
			player.velocity = Vector2.ZERO
			print("Player is in placement mode")
			create_new_tower()
	elif Btype == "TOP":
		$"Top Button Menu".show()
	elif Btype == "RIGHT":
		$"Right Button Menu".show()

func _on_tree_entered():
	$"Left Button Menu".hide()
	$"Top Button Menu".hide()
	$"Right Button Menu".hide()
	resize_ui()
	if Btype == "LEFT":
		$"Left Button Menu".show()
	elif Btype == "TOP":
		$"Top Button Menu".show()
	elif Btype == "RIGHT":
		$"Right Button Menu".show()
	else:
		print("Build Menu entered but no type")

func resize_ui():
	var p = match_ui_to_splitscreen()
	$"Left Button Menu".offset = p
	$"Top Button Menu".offset = p
	$"Right Button Menu".offset =  p
	print(offset)

func match_ui_to_splitscreen():
	var p
	if len(MultiplayerControls.players) == 2:
		p = Vector2(-Settings.resolution_x/4,0)
	elif len(MultiplayerControls.players) == 3:
		p = Vector2(-Settings.resolution_x/3,0)
	elif len(MultiplayerControls.players) == 4:
		p = Vector2(-Settings.resolution_x/4,-Settings.resolution_y/4)
	else:
		return Vector2(0,0)
	return p

func create_new_tower():
	current_tower = prebuild(GamePaths.Tower)

func prebuild(x):
	#shows the tower in either a shadow using shader or outline as if it needs to be places in front of player
	var Tower = load(x)
	var tower = Tower.instantiate()
	tower.player_owner = player
	tower.owner_build_menu = self
	# TODO change this to the main game scene once we have a actual level funcitonality.
	get_tree().get_first_node_in_group("LEVELS").add_child(tower)
	return tower


func _on_tower_finished_placement():
	pass
