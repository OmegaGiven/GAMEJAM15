extends CharacterBody2D

const SPEED = 300.0
var Health = 100
var cooldown = 1 #in seconds
var destination_list = []


"""
Priority:
- If boss gets hit: summon X minions where x = health diff / 10 
1. go toward player that attacked it

"""

func detect_tower():
	pass


func detect_player():
	
	pass


func go_toward_base():
	pass


func next_destination():
	#NavigationAgent2D
	pass


func _physics_process(delta):
	# enemy movement
	pass


#if cooldown use timers get_tree().timer(cooldown)
func _process(delta):
# detect stuff
	pass


var objects_in_detection_area = []

func _on_area_2d_body_entered(body):
	print("object entered: ",body)
	if body not in objects_in_detection_area:
		objects_in_detection_area.append(body)

func _on_area_2d_body_exited(body):
	if body in objects_in_detection_area:
		objects_in_detection_area.erase(body)
