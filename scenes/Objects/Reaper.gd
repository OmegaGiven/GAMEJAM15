extends CharacterBody2D

const WANDER_SPEED = 20
const CHASE_SPEED = 55
const ATTACK_RANGE = 45
const CHASE_RANGE = 350

@export var health = 100
@export var type = "enemy"

var cooldown = 1.5
var spawn_point: Vector2
var WANDER_RADIUS = 250
var random_point: Vector2
var last_hit_health = 100
var attack_timer = 0.0
var attack_damage = 2
var dying = false

var Spirit = preload("res://scenes/Objects/Spirit.tscn")

signal reaper_defeated(death_position: Vector2)

func _ready():
	spawn_point = self.position
	$reaper_attack.hide()
	$reaper_death.hide()
	self.add_to_group("enemy")
	random_point = get_random_goto_point()
	last_hit_health = health

func get_random_goto_point() -> Vector2:
	var rand_angle = randf_range(0, 2 * PI)
	var rand_radius = randf_range(0, WANDER_RADIUS)
	return spawn_point + Vector2(cos(rand_angle), sin(rand_angle)) * rand_radius

func find_closest_target():
	var closest = null
	var min_dist = CHASE_RANGE
	for node in get_tree().get_nodes_in_group("base"):
		var d = global_position.distance_to(node.global_position)
		if d < min_dist:
			min_dist = d
			closest = node
	for node in get_tree().get_nodes_in_group("player"):
		if is_instance_valid(node):
			var d = global_position.distance_to(node.global_position)
			if d < min_dist:
				min_dist = d
				closest = node
	return closest

func spawn_minions(count: int):
	for i in count:
		var minion = Spirit.instantiate()
		minion.global_position = global_position + Vector2(randf_range(-60, 60), randf_range(-60, 60))
		get_parent().add_child(minion)

func _physics_process(delta):
	if dying:
		velocity = Vector2.ZERO
		return
	if health <= 0:
		seppuku()
		return
	var target = find_closest_target()
	if target:
		var dist = global_position.distance_to(target.global_position)
		if dist > ATTACK_RANGE:
			velocity = global_position.direction_to(target.global_position) * CHASE_SPEED
		else:
			velocity = Vector2.ZERO
			attack_timer -= delta
			if attack_timer <= 0:
				target.health -= attack_damage
				attack_timer = cooldown
	else:
		var direction = random_point - position
		if direction.length() < 10:
			random_point = get_random_goto_point()
		velocity = direction.normalized() * WANDER_SPEED
	move_and_slide()

func _process(_delta):
	if dying:
		return
	if health <= 0:
		seppuku()
		return
	var health_lost = last_hit_health - health
	if health_lost >= 10:
		var count = int(health_lost / 10)
		spawn_minions(count)
		last_hit_health = health

func seppuku():
	if dying:
		return
	dying = true
	$reaper_idle.hide()
	$reaper_attack.hide()
	$reaper_death.show()
	$AnimationPlayer.play("death")
	emit_signal("reaper_defeated", global_position)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "death":
		self.queue_free()

var objects_in_detection_area = []

func _on_area_2d_body_entered(body):
	if body not in objects_in_detection_area:
		objects_in_detection_area.append(body)

func _on_area_2d_body_exited(body):
	if body in objects_in_detection_area:
		objects_in_detection_area.erase(body)
