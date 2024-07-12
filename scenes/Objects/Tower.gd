extends RigidBody2D

var Health = 100
var player_owner
var owner_build_menu
@onready var in_placement = true
@onready var actually_placing = false

func _ready():
	if player_owner != null:
		self.position = SplitScreenFunctionality.player_characters[player_owner.device_num]["camera"].position

func _input(event):
	if in_placement:
		if player_owner != null and event.is_action_pressed("BOTTOM_action{n}".format({"n":player_owner.device_num})):
			if actually_placing:
				if player_owner.resources >= 50:
					place_tower()
				else:
					print("Not enough resources, current amount {n}".format({"n": player_owner.resources}))
			else:
				actually_placing = !actually_placing

func place_tower():
		in_placement = !in_placement
		player_owner.resources -= 50
		print("Tower bought and placed, Resources: {G}".format({"G": player_owner.resources}))
		player_owner.owned_towers.append(self)
		self.set_collision_layer_value(6, true)
		owner_build_menu.create_new_tower()


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




