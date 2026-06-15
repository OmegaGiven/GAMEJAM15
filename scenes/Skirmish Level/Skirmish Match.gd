extends Node2D

var Bonfire = preload("res://scenes/Objects/bonfire.tscn")
var Tree    = preload("res://scenes/Objects/tree1.tscn")
var Spirit  = preload("res://scenes/Objects/Spirit.tscn")
var Reaper  = preload("res://scenes/Objects/Reaper.tscn")

# Clover petal positions (center of each player's base, relative to map origin)
const PETAL_POSITIONS = {
	2: [Vector2(-500, 0), Vector2(500, 0)],
	3: [Vector2(0, -500), Vector2(-433, 250), Vector2(433, 250)],
	4: [Vector2(-400, -400), Vector2(400, -400), Vector2(-400, 400), Vector2(400, 400)],
}

var wave_timer = 0.0
var current_wave_interval: float
var wave_number = 0
var game_over = false
var reaper_node: Node = null

# bonfire node -> player index (0-based)
var bonfire_owners: Dictionary = {}
var active_bonfires: Array = []

func _ready():
	self.add_child(SplitScreenFunctionality.scene_splitscreen)
	SplitScreenFunctionality.add_splitscreen_to_scene()
	$HBoxContainer/SubViewportContainer/PauseMenu.hide()
	current_wave_interval = Settings.wave_interval
	call_deferred("_setup_level")

func _setup_level():
	var level = get_tree().get_first_node_in_group("LEVELS")
	var player_count = clampi(MultiplayerControls.players.size(), 2, 4)
	var petal_positions: Array = PETAL_POSITIONS[player_count]

	for i in petal_positions.size():
		var petal = petal_positions[i]

		# Bonfire at petal center
		var bonfire = Bonfire.instantiate()
		bonfire.position = petal
		level.add_child(bonfire)
		bonfire.fire_extinguished.connect(_on_bonfire_out.bind(bonfire))
		bonfire_owners[bonfire] = i
		active_bonfires.append(bonfire)

		# 5 trees around each petal in a ring
		for t in 5:
			var tree = Tree.instantiate()
			var angle = (2.0 * PI / 5.0) * t
			tree.position = petal + Vector2(cos(angle), sin(angle)) * 130
			level.add_child(tree)

	# Reaper roams the center
	var reaper = Reaper.instantiate()
	reaper.position = Vector2.ZERO
	reaper.WANDER_RADIUS = 150
	reaper.reaper_defeated.connect(_on_reaper_defeated)
	level.add_child(reaper)
	reaper_node = reaper

	# Spawn points evenly spaced on outer ring
	var spawn_count = max(4, player_count * 2)
	for i in spawn_count:
		var angle = (2.0 * PI / float(spawn_count)) * i
		var sp = Node2D.new()
		sp.name = "SkirmishSpawn%d" % i
		sp.position = Vector2(cos(angle), sin(angle)) * 750
		sp.add_to_group("spawn_point")
		level.add_child(sp)

func _process(delta):
	if game_over:
		return
	wave_timer += delta
	if wave_timer >= current_wave_interval:
		wave_timer = 0.0
		_spawn_wave()

func _spawn_wave():
	wave_number += 1

	# Escalate: interval shrinks each wave, count and health scale up
	current_wave_interval = maxf(5.0, Settings.wave_interval - wave_number * 1.5)
	var per_fire = wave_number + 1
	var total_count = mini(per_fire * active_bonfires.size(), 16)
	var health_scale = 1.0 + wave_number * 0.15
	var damage_scale = 1.0 + wave_number * 0.1

	var level = get_tree().get_first_node_in_group("LEVELS")
	var spawn_points = get_tree().get_nodes_in_group("spawn_point")

	for i in total_count:
		var spirit = Spirit.instantiate()
		spirit.health = int(10.0 * health_scale)
		spirit.DAMAGE = int(5.0 * damage_scale)
		if spawn_points.size() > 0:
			var sp = spawn_points[randi() % spawn_points.size()]
			spirit.position = sp.global_position
		else:
			var angle = randf_range(0.0, 2.0 * PI)
			spirit.position = Vector2(cos(angle), sin(angle)) * 750
		if level:
			level.add_child(spirit)

	print("Skirmish wave %d — %d spirits | next in %.0fs | health x%.2f" % [
		wave_number, total_count, current_wave_interval, health_scale
	])

func _on_bonfire_out(bonfire_node: Node):
	if not bonfire_node in bonfire_owners:
		return
	var player_idx = bonfire_owners[bonfire_node]
	active_bonfires.erase(bonfire_node)
	print("Player %d's fire is out! (%d fires remaining)" % [player_idx + 1, active_bonfires.size()])
	_check_win()

func _on_reaper_defeated(death_position: Vector2):
	print("Reaper slain at %s — buffing nearest player!" % str(death_position))
	_buff_nearest_player(death_position)
	reaper_node = null

func _buff_nearest_player(pos: Vector2):
	var nearest = null
	var min_dist = INF
	for player in get_tree().get_nodes_in_group("player"):
		if is_instance_valid(player) and player.health > 0:
			var d = player.global_position.distance_to(pos)
			if d < min_dist:
				min_dist = d
				nearest = player
	if nearest:
		nearest.activate_reaper_power()

func _check_win():
	if game_over:
		return
	if active_bonfires.size() <= 1:
		game_over = true
		if active_bonfires.size() == 1:
			var winner = bonfire_owners[active_bonfires[0]]
			print("PLAYER %d WINS!" % (winner + 1))
		else:
			print("ALL FIRES OUT — DRAW!")
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file(GamePaths.main_menu)
