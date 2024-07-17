extends CanvasLayer


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		self.visible = !visible


func _on_exit_pressed():
	get_tree().quit()


func _on_main_menu_pressed():
	MultiplayerControls.in_main_menu = true
	var level = get_tree().get_first_node_in_group("LEVELS")
	for x in MultiplayerControls.players:
		level.remove_child(x)
	$"../../..".remove_child(SplitScreenFunctionality.scene_splitscreen)
	get_tree().change_scene_to_file(GamePaths.main_menu)


func _on_visibility_changed():
	if visible:
		$VBoxContainer/Return.grab_focus()
