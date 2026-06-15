extends Node2D

@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var MASTER_BUS_ID = AudioServer.get_bus_index("Master")

const RESOLUTIONS = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160),
]

func _ready():
	self.hide()
	self.position = Vector2(floor(Settings.resolution_x) / 2.0, floor(Settings.resolution_y) / 2.0)

	# Audio tab
	$TabContainer/Audio/Master2.value = Settings.master
	$TabContainer/Audio/Music2.value = Settings.music
	$TabContainer/Audio/SFX2.value = Settings.sfx

	# Display tab — populate resolution options
	var res_option = $TabContainer/Display/Resolution
	for r in RESOLUTIONS:
		res_option.add_item("%d x %d" % [r.x, r.y])
	var current = Vector2i(Settings.resolution_x, Settings.resolution_y)
	var idx = RESOLUTIONS.find(current)
	res_option.selected = idx if idx >= 0 else 1

	# Reflect current window state
	$TabContainer/Display/Fullscreen.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	$TabContainer/Display/VSync.button_pressed = DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		self.hide()
		$"../Menu".show()

func _on_visibility_changed():
	if self.visible:
		$TabContainer/Audio/Master2.grab_focus()

# --- Audio ---

func _on_master_2_value_changed(value):
	Settings.master = value
	AudioServer.set_bus_volume_db(MASTER_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MASTER_BUS_ID, value < 0.05)

func _on_music_2_value_changed(value):
	Settings.music = value
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < 0.05)

func _on_sfx_2_value_changed(value):
	Settings.sfx = value
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < 0.05)

# --- Display ---

func _on_resolution_item_selected(index):
	var res = RESOLUTIONS[index]
	Settings.resolution_x = res.x
	Settings.resolution_y = res.y
	DisplayServer.window_set_size(res)

func _on_fullscreen_toggled(pressed):
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		$TabContainer/Display/Fullscreen.text = "On"
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		$TabContainer/Display/Fullscreen.text = "Off"

func _on_vsync_toggled(pressed):
	if pressed:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		$TabContainer/Display/VSync.text = "On"
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		$TabContainer/Display/VSync.text = "Off"
