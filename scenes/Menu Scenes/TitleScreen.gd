extends Node2D


func _ready():
	self.position = Vector2(floor(Settings.resolution_x)/2.0, floor(Settings.resolution_y)/2.0)
	$VBoxContainer/Tutorial.grab_focus()


func _on_exit_pressed():
	get_tree().quit()


func _on_arcade_pressed():
	self.hide()
	$"../ArcadeMenu".show()


func _on_visibility_changed():
	if self.visible:
		$VBoxContainer/Tutorial.grab_focus()


func _on_settings_pressed():
	self.hide()
	$"../SettingsMenu".show()


func _on_tutorial_pressed():
	MultiplayerControls.in_main_menu = false
	get_tree().change_scene_to_file(GamePaths.tutorial_level)
