extends StaticBody2D


var health: float:
	get:
		return health
	set(x):
		health = x
		hit_animation()
		print(health)
		

@export var type = "resource"

func _ready():
	health = 100
	
func hit_animation():
#play hit animation
	if health <= 0:
		queue_free()
