extends Control


@onready var progress_bar = $progressBar
@onready var hp_Container = $HpContainer
 
@export var sprite : Sprite2D
@export var health_texture : PackedScene

@export var max_health = 5

var cur_health : int = 0
var max_health_size


# Called when the node enters the scene tree for the first time.
func _ready():
	reciveHp(max_health)
	max_health_size = 3 + 4 * max_health
	cur_health = max_health
	progress_bar.size.x = (max_health_size)
	progress_bar.position.x = sprite.position.x
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func reciveHp(health_recived):
	
	if cur_health >= max_health:
		return
	for i in health_recived:
		var hp_tick = health_texture.instantiate()
		hp_Container.add_child(hp_tick)
		cur_health += 1
		

func damage(damage_recived):
	for i in damage_recived:
		hp_Container.get_child(hp_Container.get_child_count()-1).queue_free()
		cur_health -= 1 
		if cur_health == 0:
			get_parent().queue_free()
			break
	
