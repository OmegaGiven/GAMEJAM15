extends StaticBody2D

var _health: float = 0.0
var health: float:
	get:
		return _health
	set(x):
		_health = x
		hit_animation()

@export var type = "resource"

func _ready():
	health = 50

func hit_animation():
	if _health <= 0:
		queue_free()
