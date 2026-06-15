extends Node2D

func _ready():
	self.position = Vector2(Settings.resolution_x / 2.0, Settings.resolution_y / 2.0)
	$VBoxContainer/Mode.add_item("Arcade Match")
	$VBoxContainer/Mode.add_item("Skirmish")
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
		$VBoxContainer/Teams.clear()
		for x in len(MultiplayerControls.players):
			$VBoxContainer/Teams.add_item(str(x + 1) + " Players")
		$VBoxContainer/Mode.grab_focus()

func _on_start_match_pressed():
	MultiplayerControls.in_main_menu = false
	var mode = $VBoxContainer/Mode.selected
	if mode == 1:
		get_tree().change_scene_to_file(GamePaths.skirmish_match)
	else:
		get_tree().change_scene_to_file(GamePaths.arcade_match)
