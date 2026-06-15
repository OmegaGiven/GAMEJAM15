extends Node2D

var Spirit = preload("res://scenes/Objects/Spirit.tscn")

var wave_timer = 0.0
var wave_interval = 20.0
var wave_number = 0
var game_over = false

func _ready():
	self.add_child(SplitScreenFunctionality.scene_splitscreen)
	SplitScreenFunctionality.add_splitscreen_to_scene()
	$HBoxContainer/SubViewportContainer/PauseMenu.hide()

	# Wire up signals after scene is fully built
	call_deferred("_connect_signals")

func _connect_signals():
	for node in get_tree().get_nodes_in_group("base"):
		if node.has_signal("fire_extinguished"):
			node.fire_extinguished.connect(_on_fire_out)

	var reaper = _find_reaper(self)
	if reaper:
		reaper.reaper_defeated.connect(_on_reaper_defeated)

func _find_reaper(node: Node):
	for child in node.get_children():
		if child.get_script() and child.get_script().resource_path.ends_with("Reaper.gd"):
			return child
		var found = _find_reaper(child)
		if found:
			return found
	return null

func _process(delta):
	if game_over:
		return
	wave_timer += delta
	if wave_timer >= wave_interval:
		wave_timer = 0.0
		spawn_wave()

func spawn_wave():
	wave_number += 1
	var count = min(wave_number * 2 + 1, 10)
	var spawn_points = get_tree().get_nodes_in_group("spawn_point")

	for i in count:
		var spirit = Spirit.instantiate()
		if spawn_points.size() > 0:
			var sp = spawn_points[randi() % spawn_points.size()]
			spirit.global_position = sp.global_position
		else:
			var angle = randf_range(0, 2 * PI)
			spirit.global_position = Vector2(cos(angle), sin(angle)) * 600
		add_child(spirit)

	print("Wave %d — %d spirits" % [wave_number, count])

func _on_reaper_defeated():
	if game_over:
		return
	game_over = true
	print("YOU WIN — the Reaper is defeated!")
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file(GamePaths.main_menu)

func _on_fire_out():
	if game_over:
		return
	game_over = true
	print("FIRE OUT — darkness wins!")
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file(GamePaths.main_menu)
