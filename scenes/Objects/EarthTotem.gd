extends "res://scenes/Objects/BasicTotem.gd"

func _ready():
	super._ready()
	wood_cost = 20
	earth_cost = 10.0
	add_to_group("taunt")

func get_build_type() -> String:
	return "earth"
