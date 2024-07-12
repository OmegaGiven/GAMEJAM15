extends Node

var master = 0.5
var sfx = 0.5
var music = 0.5

var in_menu = false
var menu_user = -1
var current_level = null

@export var resolution_x = 1920
@export var resolution_y = 1080

func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx)
