extends Node2D

func _ready():
	Settings.current_level = $"."
	self.add_child(SplitScreenFunctionality.scene_splitscreen)
	SplitScreenFunctionality.add_splitscreen_to_scene()
	$HBoxContainer/SubViewportContainer/PauseMenu.hide()

