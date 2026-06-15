extends Node2D

const ORBIT_RADIUS = 28.0
const ORBIT_SPEED = 2.0
const HOP_INTERVAL = 1.8
const TRANSIT_SPEED = 110.0
const ENERGY_DELIVERED = 3.0

var element_type: String = "water"
var current_node = null
var orbit_angle: float = 0.0
var hop_timer: float = 0.0
var in_transit: bool = false

# per-node fork memory: {node -> {neighbor_totem -> skip_count}}
var fork_memory: Dictionary = {}

func init(spot, elem_type: String):
	current_node = spot
	element_type = elem_type
	orbit_angle = randf_range(0.0, TAU)
	$Polygon2D.color = Color.CYAN if elem_type == "water" else Color.GREEN_YELLOW

func _process(delta):
	if current_node == null or not is_instance_valid(current_node):
		queue_free()
		return

	if in_transit:
		var target = current_node.global_position
		global_position = global_position.move_toward(target, TRANSIT_SPEED * delta)
		if global_position.distance_to(target) < 5.0:
			in_transit = false
		return

	orbit_angle += ORBIT_SPEED * delta
	global_position = current_node.global_position + Vector2(cos(orbit_angle), sin(orbit_angle)) * ORBIT_RADIUS

	hop_timer += delta
	if hop_timer >= HOP_INTERVAL:
		hop_timer = 0.0
		_evaluate_hop()

func _evaluate_hop():
	if _is_on_totem():
		for base in current_node.nearby_bases:
			if is_instance_valid(base):
				_deliver()
				return

	var candidates = _get_candidates()
	if candidates.is_empty():
		return

	var chosen = _weighted_pick(candidates)
	current_node = chosen
	in_transit = true

func _get_candidates() -> Array:
	var results = []
	if not _is_on_totem():
		for totem in current_node.nearby_totems:
			if not is_instance_valid(totem) or totem.in_placement or totem.owner_player == null:
				continue
			var chain_len = _bfs_chain_length(totem, totem.owner_player)
			if chain_len > 0:
				results.append({"totem": totem, "chain_len": chain_len})
	else:
		var owner = current_node.owner_player
		for totem in current_node.nearby_totems:
			if not is_instance_valid(totem) or totem.in_placement or totem.owner_player != owner:
				continue
			var chain_len = _bfs_chain_length(totem, owner)
			if chain_len > 0:
				results.append({"totem": totem, "chain_len": chain_len})
	return results

func _bfs_chain_length(start_totem, owner) -> int:
	var visited = {}
	var queue = [[start_totem, 1]]
	while not queue.is_empty():
		var pair = queue.pop_front()
		var node = pair[0]
		var depth = pair[1]
		if node in visited:
			continue
		visited[node] = true
		for base in node.nearby_bases:
			if is_instance_valid(base):
				return depth
		for neighbor in node.nearby_totems:
			if is_instance_valid(neighbor) and neighbor.owner_player == owner and neighbor not in visited:
				queue.append([neighbor, depth + 1])
	return 0

func _weighted_pick(candidates: Array) -> Node:
	if not (current_node in fork_memory):
		fork_memory[current_node] = {}
	var memory: Dictionary = fork_memory[current_node]

	var total = 0.0
	for c in candidates:
		# longer chain = more developed network = higher base weight
		# skip_boost: unchosen paths accumulate bonus so they eventually win
		var skips = memory.get(c["totem"], 2)
		c["w"] = float(c["chain_len"]) * (1.0 + skips * 0.5)
		total += c["w"]

	var roll = randf() * total
	var acc = 0.0
	var chosen: Node = candidates[0]["totem"]
	for c in candidates:
		acc += c["w"]
		if roll <= acc:
			chosen = c["totem"]
			break

	for c in candidates:
		if c["totem"] == chosen:
			memory[c["totem"]] = 0
		else:
			memory[c["totem"]] = memory.get(c["totem"], 0) + 1

	return chosen

func _deliver():
	if is_instance_valid(current_node) and current_node.owner_player != null:
		current_node.owner_player.add_elemental_energy(element_type, ENERGY_DELIVERED)
		print("Ball: %.0f %s → player %d" % [ENERGY_DELIVERED, element_type, current_node.owner_player.device_num])
	queue_free()

func _is_on_totem() -> bool:
	return current_node != null and current_node.is_in_group("totem")
