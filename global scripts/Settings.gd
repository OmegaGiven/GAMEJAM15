extends Node

# Audio
var master = 0.5
var sfx = 0.5
var music = 0.5
var voice = 0.5

# Display
var resolution_x = 1920
var resolution_y = 1080
var window_mode = 1  # 0=Windowed 1=Borderless 2=Fullscreen
var vsync = true
var hud_scale = 1.0

# Gameplay
var wave_interval = 20.0
var starting_resources = 100

const DARKNESS = 1.0
var in_menu = false
var menu_user = -1
var current_level = null

func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx))
