extends CanvasLayer

var player
var Btype
var current_tower

func _input(event):
	if player.in_placement_mode:
		if event.is_action_pressed("RIGHT_action{n}".format({"n": player.device_num})):
			player.in_placement_mode = false
			player.free_cam = false
			print("Canceling placement")
			if current_tower and current_tower.in_placement:
				get_tree().get_first_node_in_group("LEVELS").remove_child(current_tower)
			player.toggle_build_menu()
	elif Btype == "LEFT":
		if event.is_action_pressed("BOTTOM_action{n}".format({"n": player.device_num})) or event.is_action_pressed("left_mouse_click"):
			_enter_placement("basic")
	elif Btype == "TOP":
		if event.is_action_pressed("BOTTOM_action{n}".format({"n": player.device_num})):
			_enter_placement("water")
		elif event.is_action_pressed("RIGHT_action{n}".format({"n": player.device_num})):
			_enter_placement("earth")

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

func resize_ui():
	var p = match_ui_to_splitscreen()
	$"Left Button Menu".offset = p
	$"Top Button Menu".offset = p
	$"Right Button Menu".offset = p

func match_ui_to_splitscreen():
	if len(MultiplayerControls.players) == 2:
		return Vector2(-floor(Settings.resolution_x) / 4.0, 0)
	elif len(MultiplayerControls.players) == 3:
		return Vector2(-floor(Settings.resolution_x) / 3.0, 0)
	elif len(MultiplayerControls.players) == 4:
		return Vector2(-floor(Settings.resolution_x) / 4.0, -floor(Settings.resolution_y) / 4.0)
	return Vector2.ZERO

func _enter_placement(build_type: String):
	$"Left Button Menu".hide()
	$"Top Button Menu".hide()
	$"Right Button Menu".hide()
	player.in_placement_mode = true
	player.free_cam = true
	player.velocity = Vector2.ZERO
	_build(build_type)

func _build(build_type: String):
	current_tower = prebuild(GamePaths.get(build_type + "_totem"))

func prebuild(scene_path: String):
	if scene_path == null or scene_path == "":
		print("No scene path for totem type")
		return null
	var Scene = load(scene_path)
	var totem = Scene.instantiate()
	totem.owner_player = player
	totem.owner_build_menu = self
	get_tree().get_first_node_in_group("LEVELS").add_child(totem)
	return totem

func on_totem_placed(build_type: String):
	_build(build_type)

# Legacy
func create_new_tower():
	_build("basic")

func create_new_basic_totem():
	_build("basic")

# --- Button signals ---

func _on_left_basic_pressed():
	_request_totem("basic", 10, 0.0, 0.0)

func _on_left_fire_pressed():
	_request_totem("fire", 15, 0.0, 0.0)

func _on_top_water_pressed():
	_request_totem("water", 20, 10.0, 0.0)

func _on_top_earth_pressed():
	_request_totem("earth", 20, 0.0, 10.0)

func _request_totem(build_type: String, wood: int, water: float, earth: float):
	if not player.can_place_totem(build_type):
		print("P%d: %s cap (%d) reached — destroy one first" % [player.device_num, build_type, player.MAX_TOTEMS_PER_TYPE])
		return
	if player.consume_inventory(build_type):
		_enter_placement(build_type)
	else:
		player.start_craft(build_type, wood, water, earth)
