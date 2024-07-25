extends CharacterBody2D

const SPEED = 300.0

@export var health = 100
@export var type = "enemy"

var cooldown = 1 #in seconds
var destination_list = []


"""
Priority:
- If boss gets hit: summon X minions where x = health diff / 10

idle: wanders around the top area

smaller guys wander toward closes light source

1. go toward player that attacked it

"""

func _ready():
	$reaper_attack.hide()
	$reaper_death.hide()
	self.add_to_group("enemy")

func detect_tower():
	pass


func detect_player():
	
	pass


func go_toward_base():
	pass


func next_destination():
	#NavigationAgent2D
	pass


func _physics_process(_delta):
	# enemy movement
	pass


func _process(_delta):
	if health <= 0:
		seppuku()


func seppuku():
	$reaper_idle.hide()
	$reaper_death.show()
	$AnimationPlayer.play("death")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "death":
		self.queue_free()


var objects_in_detection_area = []

func _on_area_2d_body_entered(body):
	print("object entered: ",body)
	if body not in objects_in_detection_area:
		objects_in_detection_area.append(body)

func _on_area_2d_body_exited(body):
	if body in objects_in_detection_area:
		objects_in_detection_area.erase(body)
