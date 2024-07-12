extends Node2D

var animated_sprite: AnimatedSprite2D


func _ready():
	animated_sprite = $AnimatedSprite2D
	animated_sprite.play("drop animation")


func _on_body_entered(body):
	if body.player_name != null:
		body.resources += 10
		print("Player {n} picked up gold resources are now: {G}".format({"n": body.device_num, "G": body.resources}))
# TODO add gold ching sound
		self.queue_free()


func _on_animated_sprite_2d_animation_finished():
	animated_sprite.play("idle_animation")
