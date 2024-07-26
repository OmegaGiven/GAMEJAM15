extends RigidBody2D

@export var hp_bar : Control
var health: float:
	get:
		return health
	set(x):
		health = x
		print(health)
		change_lighting()
@export var type = "base"



func _ready():
	health = 10
	pass


func _process(_delta):
	#if Input.is_action_just_pressed("debug"):
		#hp_bar.damage(1)
	pass



func add_fuel(wood):
	health += wood
	emit_signal("health_changed",  health)


func change_lighting():
	var min = 0.55
	var max = 0.8
	var range = max - min
	var lumin = health / (range * 10000)
	print("lumin", lumin)
	$PointLight2D.texture.fill_to.y = lumin + min
	#if health >= 100:
		#$PointLight2D.texture.fill_to.y = 0.8
	#elif health <= 10:
		#$PointLight2D.texture.fill_to.y = 0.55
	#else:
		#$PointLight2D.texture.fill_to.y = 0.0035 * health + 0.2



"""
health = 100
Max luminocity To = 0.1
+- 0.05
MIN luminicty To = 0.45
if health >= 100 then light == 0.1
0.0016 = 1hp
100 / 0.1 = 

TO = 0.0035 * health + 0.1

Luminocty = 

1-100
"""
