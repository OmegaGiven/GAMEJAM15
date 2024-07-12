extends Node

@onready var player_characters := {}
@onready var scene_splitscreen = HBoxContainer.new()


func add_splitscreen_to_scene():
	for player in MultiplayerControls.players:
		# replace this scene with needed scene for split screen
		if player not in get_tree().get_first_node_in_group("LEVELS").get_children(): #  $HBoxContainer/SubViewportContainer/SubViewport/Level
			get_tree().get_first_node_in_group("LEVELS").add_child(player) # puts player in level $HBoxContainer/SubViewportContainer/SubViewport/Level
			print("Placing Player in scene: {n}".format({"n": player.device_num}))
			if player_characters.get(player.device_num) == null:
				print("Creating splitscreen for palyer")
				var player_viewport_container = SubViewportContainer.new()
				scene_splitscreen.add_child(player_viewport_container)
				var player_viewport = SubViewport.new()# create new viewport for player
				player_viewport_container.add_child(player_viewport)
				var player_camera = Camera2D.new()# create new camera to go in viewport
				player_viewport.add_child(player_camera)
				player_viewport.world_2d = get_tree().get_first_node_in_group("GAME_VIEWPORT").world_2d # $HBoxContainer/SubViewportContainer/SubViewport
				print("2d word: ", player_viewport.world_2d)
				player_characters[player.device_num]={
									"container" = player_viewport_container,
									"viewport" = player_viewport,#put dynamically created viewport here
									"camera" = player_camera,#put dynamic camera here
									"player" = player,
								}
				
				var s = size()
				if s == null:
					pass #todo for if we want to incoorperate 4+ players with no split screen
				else:
					#go back through and resize all players viewports to new sizing.
					for x in player_characters:
						player_characters[x]["viewport"].size = Vector2(s[0],s[1])
				#self.add_child(player) #for putting player
			else:
				player_characters[player.device_num]["viewport"].world_2d = get_tree().get_first_node_in_group("GAME_VIEWPORT").world_2d # $HBoxContainer/SubViewportContainer/SubViewport


func size():
	var x = Settings.resolution_x
	var y = Settings.resolution_y
	if len(MultiplayerControls.players) == 2:
		x = x/2
	elif len(MultiplayerControls.players) == 3:
		x = x/3
	elif len(MultiplayerControls.players) == 4:
		x = x/2
		y = y/2
	elif len(MultiplayerControls.players) > 4:
		return null
	print("size of each split screen: {x}, {y}".format({"x":x, "y":y}))
	return [x, y]

