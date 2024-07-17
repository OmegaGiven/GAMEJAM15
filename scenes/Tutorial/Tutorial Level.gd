extends Node2D


func _ready():
	spawn()
	pass


func spawn():
	#1. Player Spawns in
	for player in MultiplayerControls.players:
		var SpawnableLocation = load(GamePaths.spawnable_location).instantiate()
		add_child(SpawnableLocation)
		player.global_position = SpawnableLocation.find_spawnable_location($"Tutorial Spawn".global_position.x, $"Tutorial Spawn".global_position.y)
		print("Spawned player at {n}".format({"n": player.global_position}))
		await get_tree().create_timer(.1).timeout
		remove_child(SpawnableLocation)


# set dialogue box to open globally
# create dialoge box (dialogue list)
