extends StaticBody2D

const ElementalBall = preload("res://scenes/Objects/ElementalBall.tscn")

@export var element_type: String = "water"
@export var spawn_interval: float = 8.0
@export var max_balls: int = 3

var nearby_totems: Array = []
var active_balls: Array = []
var spawn_timer: float = 0.0

func _ready():
	add_to_group("elemental_spot")
	add_to_group(element_type + "_spot")
	# Stagger first spawn so all spots don't fire at once
	spawn_timer = randf_range(0.0, spawn_interval)

func _process(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_try_spawn_ball()

func _try_spawn_ball():
	# Clean up freed balls
	active_balls = active_balls.filter(func(b): return is_instance_valid(b))
	if active_balls.size() >= max_balls:
		return
	# Only spawn if at least one placed totem is in range with a bonfire path
	var has_viable_totem = false
	for totem in nearby_totems:
		if is_instance_valid(totem) and not totem.in_placement and totem.owner_player != null:
			has_viable_totem = true
			break
	if not has_viable_totem:
		return

	var ball = ElementalBall.instantiate()
	ball.global_position = global_position
	var level = get_tree().get_first_node_in_group("LEVELS")
	if level == null:
		return
	level.add_child(ball)
	ball.init(self, element_type)
	active_balls.append(ball)

func _on_area_2d_body_entered(body):
	if body.is_in_group("totem") and body not in nearby_totems:
		nearby_totems.append(body)

func _on_area_2d_body_exited(body):
	nearby_totems.erase(body)
