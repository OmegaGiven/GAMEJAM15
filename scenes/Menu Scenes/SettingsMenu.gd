extends Node2D

@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var MASTER_BUS_ID = AudioServer.get_bus_index("Master")
var VOICE_BUS_ID = -1

const RESOLUTIONS = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160),
]

func _ready():
	self.hide()
	self.position = Vector2(floor(Settings.resolution_x) / 2.0, floor(Settings.resolution_y) / 2.0)
	VOICE_BUS_ID = AudioServer.get_bus_index("Voice")

	_init_audio()
	_init_display()
	_init_gameplay()

func _init_audio():
	$TabContainer/Audio/Master2.value = Settings.master
	$TabContainer/Audio/Music2.value = Settings.music
	$TabContainer/Audio/SFX2.value = Settings.sfx
	$TabContainer/Audio/Voice2.value = Settings.voice
	if VOICE_BUS_ID == -1:
		$TabContainer/Audio/Voice2.editable = false
		$TabContainer/Audio/VoiceLabel.text = "Voice (not yet implemented)"

func _init_display():
	var win_opt = $TabContainer/Display/WindowMode
	win_opt.add_item("Windowed")
	win_opt.add_item("Borderless")
	win_opt.add_item("Fullscreen")
	win_opt.selected = Settings.window_mode

	var res_opt = $TabContainer/Display/Resolution
	for r in RESOLUTIONS:
		res_opt.add_item("%d x %d" % [r.x, r.y])
	var current = Vector2i(Settings.resolution_x, Settings.resolution_y)
	var idx = RESOLUTIONS.find(current)
	res_opt.selected = idx if idx >= 0 else 1
	$TabContainer/Display/VSync.button_pressed = Settings.vsync
	$TabContainer/Display/HudScale.value = Settings.hud_scale

func _init_gameplay():
	$TabContainer/Gameplay/WaveInterval.value = Settings.wave_interval
	$TabContainer/Gameplay/StartResources.value = Settings.starting_resources

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

func _on_voice_2_value_changed(value):
	Settings.voice = value
	if VOICE_BUS_ID != -1:
		AudioServer.set_bus_volume_db(VOICE_BUS_ID, linear_to_db(value))
		AudioServer.set_bus_mute(VOICE_BUS_ID, value < 0.05)

# --- Display ---

func _on_resolution_item_selected(index):
	var res = RESOLUTIONS[index]
	Settings.resolution_x = res.x
	Settings.resolution_y = res.y
	DisplayServer.window_set_size(res)

func _on_window_mode_item_selected(index):
	Settings.window_mode = index
	match index:
		0:  # Windowed
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:  # Borderless
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		2:  # Fullscreen
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_vsync_toggled(pressed):
	Settings.vsync = pressed
	var mode = DisplayServer.VSYNC_ENABLED if pressed else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(mode)
	$TabContainer/Display/VSync.text = "On" if pressed else "Off"

func _on_hud_scale_value_changed(value):
	Settings.hud_scale = value

# --- Gameplay ---

func _on_wave_interval_value_changed(value):
	Settings.wave_interval = value
	$TabContainer/Gameplay/WaveIntervalValue.text = "%.0fs" % value

func _on_start_resources_value_changed(value):
	Settings.starting_resources = int(value)
	$TabContainer/Gameplay/StartResourcesValue.text = str(int(value))
