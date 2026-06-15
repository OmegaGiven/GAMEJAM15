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
		$Sprite2D.modulate = owner_player.player_color

func _input(event):
	if not in_placement or owner_player == null:
		return
	if event.is_action_pressed("BOTTOM_action{n}".format({"n": owner_player.device_num})):
		if actually_placing:
			_try_place()
		else:
			actually_placing = true

func _try_place():
	_place()

func _place():
	in_placement = false
	owner_player.owned_towers.append(self)
	self.set_collision_layer_value(7, true)
	$Sprite2D.modulate = owner_player.player_color
	_spawn_element_ball()
	print("%s placed by P%d. Wood: %d | Water: %.0f | Earth: %.0f" % [
		name, owner_player.device_num, owner_player.resources, owner_player.water_energy, owner_player.earth_energy
	])
	if owner_build_menu:
		owner_build_menu.on_totem_placed(get_build_type())

func _spawn_element_ball():
	var elem_color = get_element_color()
	if elem_color == Color.TRANSPARENT:
		return
	var ball = Polygon2D.new()
	ball.color = elem_color
	ball.polygon = PackedVector2Array([
		Vector2(7, 0), Vector2(4.95, 4.95), Vector2(0, 7),
		Vector2(-4.95, 4.95), Vector2(-7, 0), Vector2(-4.95, -4.95),
		Vector2(0, -7), Vector2(4.95, -4.95)
	])
	ball.position = Vector2(0, -85)
	add_child(ball)

func get_build_type() -> String:
	return "basic"

func get_element_color() -> Color:
	return Color.TRANSPARENT

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
