extends CharacterBody2D

const SPEED = 300.0

@export var health = 100
@export var type = "enemy"

var cooldown = 1 #in seconds
var destination_list = []
var spawn_point: Vector2
var WANDER_RADIUS = 250
var WANDER_SPEED = 20
var random_point


"""
Priority:
- If boss gets hit: summon X minions where x = health diff / 10

idle: wanders around the top area

smaller guys wander toward closes light source

1. go toward player that attacked it

"""

func _ready():
	spawn_point = self.position
	$reaper_attack.hide()
	$reaper_death.hide()
	self.add_to_group("enemy")
	random_point = get_random_goto_point()

func detect_tower():
	pass


func detect_player():
	pass


func go_toward_base():
	pass


func get_random_goto_point():
	var rand_angle = randf_range(0, 2*PI)
	var rand_radius = randf_range(0,WANDER_RADIUS)
	return spawn_point + Vector2(cos(rand_angle), sin(rand_angle)) * rand_radius


func _physics_process(_delta):
	# enemy movement
	var direction = random_point - position
	if direction.length() < 10:
		random_point = get_random_goto_point()
	velocity = direction.normalized() * WANDER_SPEED
	move_and_slide()


func _process(_delta):
	if health <= 0:
		seppuku()


func seppuku():
	$reaper_idle.hide()
	$reaper_attack.hide()
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
