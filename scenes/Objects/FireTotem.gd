extends "res://scenes/Objects/BasicTotem.gd"

const BURN_DAMAGE = 5
const BURN_INTERVAL = 3.0

var burn_timer = 0.0
var trees_in_range: Array = []

func _ready():
	super._ready()
	wood_cost = 15

func get_build_type() -> String:
	return "fire"

func get_element_color() -> Color:
	return Color(1.0, 0.45, 0.05)

func _process(delta):
	super._process(delta)
	if in_placement:
		return
	burn_timer -= delta
	if burn_timer <= 0:
		burn_timer = BURN_INTERVAL
		_burn_trees()

func _burn_trees():
	for tree in trees_in_range:
		if not is_instance_valid(tree):
			continue
		tree.health -= BURN_DAMAGE
		# Deliver wood to owner only if network reaches bonfire
		if owner_player != null and _connected_to_bonfire():
			owner_player.resources += BURN_DAMAGE

func _connected_to_bonfire() -> bool:
	for base in nearby_bases:
		if is_instance_valid(base):
			return true
	for neighbor in nearby_totems:
		if is_instance_valid(neighbor) and neighbor.owner_player == owner_player:
			for base in neighbor.nearby_bases:
				if is_instance_valid(base):
					return true
	return false

func _on_burn_area_body_entered(body):
	if body.type == "resource" and body not in trees_in_range:
		trees_in_range.append(body)

func _on_burn_area_body_exited(body):
	trees_in_range.erase(body)
