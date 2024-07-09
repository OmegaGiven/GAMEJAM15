extends RigidBody2D

var Health = 100
var player_owner
@onready var in_placement = true
@onready var actually_placing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if in_placement:
		if player_owner != null and event.is_action_pressed("BOTTOM_action{n}".format({"n":player_owner.device_num})):
			if actually_placing:
				if player_owner.resources >= 50:
					in_placement = !in_placement
					player_owner.resources -= 50
					print("Tower bought and placed")
					player_owner.owned_towers.append(self)
					self.set_collision_layer_value(6, true)
				else:
					print("Not enough resources, current amount {n}".format({"n": player_owner.resources}))
			else:
				actually_placing = !actually_placing

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_owner != null and in_placement:
		position += player_owner.movement() * .1
	else:
		# detect enemy()
		# attack enemy
		pass

func is_placeable():
	# show 
	pass


func detect_enemy():
	#if enemy collidable enters area 2d
		# fire
	pass




