extends Node2D


var opened_dialogue

func _ready():
	var canvas_modulate = CanvasModulate.new()
	canvas_modulate.color = Color(0, 0, 0, Settings.DARKNESS)
	add_child(canvas_modulate)
	spawn()
	intro()
	


func spawn():
	#1. Player Spawns in
	for player in MultiplayerControls.players:
		var SpawnableLocation = load(GamePaths.spawnable_location).instantiate()
		add_child(SpawnableLocation)
		player.global_position = SpawnableLocation.find_spawnable_location($"Tutorial Spawn".global_position.x, $"Tutorial Spawn".global_position.y)
		print("Spawned player at {n}".format({"n": player.global_position}))
		await get_tree().create_timer(.1).timeout
		remove_child(SpawnableLocation)

#
# set dialogue box to open globally
# create dialoge box (dialogue list)

func intro():
	opened_dialogue = DialogueCreator.CreateDialogue(TutorialDialogue.tutorial_text.Intro)
	get_tree().get_first_node_in_group("GAME_VIEWPORT").add_child(opened_dialogue)
