extends CharacterBody2D


const SPEED = 80.0

@export var health = 10
@export var type = "enemy"
@export var enemy_type = "exploding"
var DAMAGE = 5



func _ready():
	$"death animation".hide()
	self.add_to_group("enemy")


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
