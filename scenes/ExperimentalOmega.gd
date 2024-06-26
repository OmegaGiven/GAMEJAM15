extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for player in MultiplayerControls.players:
		if player not in self.get_children():
			player.scale = Vector2(2,2)
			self.add_child(player)
			await get_tree().create_timer(1).timeout
