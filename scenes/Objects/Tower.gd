extends RigidBody2D

var Health = 100
var player_owner
var owner_build_menu
@onready var in_placement = true
@onready var actually_placing = false

var attack_damage = 15
var attack_cooldown = 1.5
var attack_timer = 0.0
var enemies_in_range = []

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
					print("Not enough resources: {n}".format({"n": player_owner.resources}))
			else:
				actually_placing = !actually_placing

func place_tower():
	in_placement = !in_placement
	player_owner.resources -= 50
	print("Tower placed. Resources: {G}".format({"G": player_owner.resources}))
	player_owner.owned_towers.append(self)
	self.set_collision_layer_value(6, true)
	owner_build_menu.create_new_tower()

func _process(delta):
	if player_owner != null and in_placement:
		position += player_owner.movement() * .1
	else:
		attack_timer -= delta
		if attack_timer <= 0 and enemies_in_range.size() > 0:
			attack_nearest_enemy()
			attack_timer = attack_cooldown

func attack_nearest_enemy():
	var nearest = null
	var min_dist = INF
	for enemy in enemies_in_range:
		if is_instance_valid(enemy):
			var d = global_position.distance_to(enemy.global_position)
			if d < min_dist:
				min_dist = d
				nearest = enemy
	if nearest:
		nearest.health -= attack_damage

func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy") and body not in enemies_in_range:
		enemies_in_range.append(body)

func _on_area_2d_body_exited(body):
	enemies_in_range.erase(body)
