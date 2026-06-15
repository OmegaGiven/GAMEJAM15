extends RigidBody2D

@export var type = "totem"
var owner_player: Node = null
var owner_build_menu: Node = null
@onready var in_placement = true
@onready var actually_placing = false

# Network tracking — populated by ConnectionArea signals
var nearby_totems: Array = []
var nearby_bases: Array = []
var nearby_spots: Array = []

@export var wood_cost: int = 10
@export var water_cost: float = 0.0
@export var earth_cost: float = 0.0

func _ready():
	add_to_group("totem")
	if owner_player != null:
		position = SplitScreenFunctionality.player_characters[owner_player.device_num]["camera"].position

func _input(event):
	if not in_placement or owner_player == null:
		return
	if event.is_action_pressed("BOTTOM_action{n}".format({"n": owner_player.device_num})):
		if actually_placing:
			_try_place()
		else:
			actually_placing = true

func _try_place():
	if owner_player.resources < wood_cost:
		print("Need %d wood (have %d)" % [wood_cost, owner_player.resources])
		return
	if water_cost > 0 and owner_player.water_energy < water_cost:
		print("Need %.0f water energy (have %.0f)" % [water_cost, owner_player.water_energy])
		return
	if earth_cost > 0 and owner_player.earth_energy < earth_cost:
		print("Need %.0f earth energy (have %.0f)" % [earth_cost, owner_player.earth_energy])
		return
	_place()

func _place():
	in_placement = false
	owner_player.resources -= wood_cost
	owner_player.water_energy -= water_cost
	owner_player.earth_energy -= earth_cost
	owner_player.owned_towers.append(self)
	self.set_collision_layer_value(7, true)
	print("%s placed. Wood: %d | Water: %.0f | Earth: %.0f" % [
		name, owner_player.resources, owner_player.water_energy, owner_player.earth_energy
	])
	if owner_build_menu:
		owner_build_menu.on_totem_placed(get_build_type())

func get_build_type() -> String:
	return "basic"

func _process(_delta):
	if owner_player != null and in_placement:
		position += owner_player.movement() * 0.1

func _on_connection_area_body_entered(body):
	if body.is_in_group("totem") and body != self and body not in nearby_totems:
		nearby_totems.append(body)
	elif body.is_in_group("base") and body not in nearby_bases:
		nearby_bases.append(body)
	elif body.is_in_group("elemental_spot") and body not in nearby_spots:
		nearby_spots.append(body)

func _on_connection_area_body_exited(body):
	nearby_totems.erase(body)
	nearby_bases.erase(body)
	nearby_spots.erase(body)
