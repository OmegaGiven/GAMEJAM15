extends Node2D

@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var MASTER_BUS_ID = AudioServer.get_bus_index("Master")

func _ready():
	self.hide()
	self.position = Vector2(floor(Settings.resolution_x)/2.0, floor(Settings.resolution_y)/2.0)
	$VBoxContainer/Master2.value = Settings.master
	$VBoxContainer/Music2.value = Settings.music
	$VBoxContainer/SFX2.value =  Settings.sfx
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		self.hide()
		$"../Menu".show()

func _on_visibility_changed():
	if self.visible:
		$VBoxContainer/Master2.grab_focus()

func _on_master_2_value_changed(value):
	AudioServer.set_bus_volume_db(MASTER_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MASTER_BUS_ID, value < 0.05)

func _on_music_2_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < 0.05)

func _on_sfx_2_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < 0.05)
