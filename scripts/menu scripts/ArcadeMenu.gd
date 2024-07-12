extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	self.position = Vector2(Settings.resolution_x/2, Settings.resolution_y/2)
	$VBoxContainer/Difficulty.add_item("Easy")
	$VBoxContainer/Difficulty.add_item("Normal")
	$VBoxContainer/Difficulty.add_item("Hard")
	self.hide()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		self.hide()
		$"../Menu".show()


func _on_visibility_changed():
	if self.visible:
		# for determining how many players are connected to create teams for matches
		for x in len(MultiplayerControls.players):
			$VBoxContainer/Teams.add_item(str(x+1))
		$VBoxContainer/Difficulty.grab_focus()
	return

func _on_start_match_pressed():
	MultiplayerControls.in_main_menu = false
	get_tree().change_scene_to_file(GamePaths.arcade_match)
