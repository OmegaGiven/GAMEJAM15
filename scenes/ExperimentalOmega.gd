extends Node2D

func _ready():
	self.add_child(SplitScreenFunctionality.scene_splitscreen)
	SplitScreenFunctionality.add_splitscreen_to_scene()
