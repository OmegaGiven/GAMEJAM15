extends RigidBody2D

@export var hp_bar : Control
@export var type = "base"

const MAX_HEALTH = 200.0
const DECAY_RATE = 0.5  # health lost per second — player must keep gathering wood to survive

var _health: float = 0.0
var health: float:
	get:
		return _health
	set(x):
		_health = clamp(x, 0.0, MAX_HEALTH)
		change_lighting()
		if _health <= 0:
			fire_out()

var already_dead = false

signal fire_extinguished

func _ready():
	add_to_group("base")
	health = 100.0

func _process(delta):
	if already_dead:
		return
	health -= DECAY_RATE * delta

func add_fuel(wood):
	health += wood * 5.0

func fire_out():
	if already_dead:
		return
	already_dead = true
	emit_signal("fire_extinguished")

func change_lighting():
	# maps health 0-MAX to fill_to.y 0.55-0.80
	var fill_y = 0.55 + (_health / MAX_HEALTH) * 0.25
	$PointLight2D.texture.fill_to.y = fill_y
