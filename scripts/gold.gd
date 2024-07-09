extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.player_name != null:
		body.resources += 10
		print("Player {n} picked up gold resources are now: {G}".format({"n": body.device_num, "G": body.resources}))
		self.queue_free()
		
