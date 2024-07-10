extends Node2D


func _ready():
	self.position = Vector2(Settings.resolution_x/2, Settings.resolution_y/2)
	$VBoxContainer/Campaign.grab_focus()


func _on_exit_pressed():
	get_tree().quit()


func _on_arcade_pressed():
	self.hide()
	$"../ArcadeMenu".show()


func _on_visibility_changed():
	if self.visible:
		$VBoxContainer/Campaign.grab_focus()


func _on_settings_pressed():
	self.hide()
	$"../SettingsMenu".show()
