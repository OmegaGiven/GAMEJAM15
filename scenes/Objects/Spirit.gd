extends CharacterBody2D


const SPEED = 30.0
@export var health = 10
@export var type = "enemy"
@export var enemy_type = "exploding"
var DAMAGE = 5
var closest_node


func _ready():
	$"death animation".hide()
	self.add_to_group("enemy")
	get_closest_node()


func get_closest_node():
	var min_distance = INF
	for node in get_tree().get_nodes_in_group("base"):
		var distance = global_position.distance_to(node.global_position)
		if distance < min_distance:
			min_distance = distance
			closest_node = node

func _physics_process(_delta):
	if closest_node:
		velocity = global_position.direction_to(closest_node.global_position) * SPEED
		move_and_slide()


func _process(_delta):
	if health <= 0:
		seppuku()


func seppuku():
	$"idle anime".hide()
	$"death animation".show()
	$AnimationPlayer.play("death")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "death":
		self.queue_free()


func _on_area_2d_body_entered(body):
	if enemy_type == "exploding" and (body.type == "player" or body.type == "base"):
		body.health -= DAMAGE
		seppuku()
