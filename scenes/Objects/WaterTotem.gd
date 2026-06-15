extends "res://scenes/Objects/BasicTotem.gd"

const ATTACK_DAMAGE = 20
const ATTACK_COOLDOWN = 1.2

var attack_timer = 0.0
var enemies_in_range: Array = []

func _ready():
	super._ready()
	wood_cost = 20
	water_cost = 10.0

func get_build_type() -> String:
	return "water"

func get_element_color() -> Color:
	return Color.CYAN

func _process(delta):
	super._process(delta)
	if in_placement:
		return
	attack_timer -= delta
	if attack_timer <= 0 and enemies_in_range.size() > 0:
		_attack_nearest()
		attack_timer = ATTACK_COOLDOWN

func _attack_nearest():
	var nearest = null
	var min_dist = INF
	for target in enemies_in_range:
		if is_instance_valid(target):
			var d = global_position.distance_to(target.global_position)
			if d < min_dist:
				min_dist = d
				nearest = target
	if nearest:
		nearest.health -= ATTACK_DAMAGE

func _on_attack_area_body_entered(body):
	if body.is_in_group("enemy") and body not in enemies_in_range:
		enemies_in_range.append(body)
	elif body.type == "player" and body != owner_player and body not in enemies_in_range:
		enemies_in_range.append(body)

func _on_attack_area_body_exited(body):
	enemies_in_range.erase(body)
