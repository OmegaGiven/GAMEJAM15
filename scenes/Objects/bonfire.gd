extends RigidBody2D

@export var hp_bar : Control
@export var health = 100
@export var type = "base"

func _process(delta):
	if Input.is_action_just_pressed("debug"):
		hp_bar.damage(1)

