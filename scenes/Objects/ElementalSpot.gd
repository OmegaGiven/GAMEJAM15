extends StaticBody2D

@export var element_type: String = "water"  # "water" or "earth"
@export var energy_per_tick: float = 5.0
@export var harvest_interval: float = 5.0

var nearby_totems: Array = []
var harvest_timer: float = 0.0

func _ready():
	add_to_group("elemental_spot")
	add_to_group(element_type + "_spot")

func _process(delta):
	harvest_timer += delta
	if harvest_timer >= harvest_interval:
		harvest_timer = 0.0
		_harvest_tick()

func _harvest_tick():
	var connected_players: Dictionary = {}
	for totem in nearby_totems:
		if not is_instance_valid(totem):
			continue
		var owner = totem.owner_player
		if owner == null or owner in connected_players:
			continue
		if _has_path_to_bonfire(totem, owner):
			connected_players[owner] = true

	if connected_players.is_empty():
		return

	var share = energy_per_tick / float(connected_players.size())
	for player in connected_players:
		if is_instance_valid(player):
			player.add_elemental_energy(element_type, share)

# BFS through same-owner totems from start_totem looking for a bonfire
func _has_path_to_bonfire(start_totem: Node, owner: Node) -> bool:
	var visited: Dictionary = {}
	var queue: Array = [start_totem]
	while not queue.is_empty():
		var current = queue.pop_front()
		if current in visited:
			continue
		visited[current] = true
		for base in current.nearby_bases:
			if is_instance_valid(base):
				return true
		for neighbor in current.nearby_totems:
			if is_instance_valid(neighbor) and neighbor.owner_player == owner and neighbor not in visited:
				queue.append(neighbor)
	return false

func _on_area_2d_body_entered(body):
	if body.is_in_group("totem") and body not in nearby_totems:
		nearby_totems.append(body)

func _on_area_2d_body_exited(body):
	nearby_totems.erase(body)
