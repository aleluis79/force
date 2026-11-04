class_name Grunt
extends CharacterBody2D

## Ground enemy that walks toward the player and damages on contact.

signal died(points: int)

const GRAVITY := 900.0
const SPEED := 40.0
const CONTACT_RANGE := 18.0

@export var score_value := 100

var health := Health.new(30)
var _player: Player

@onready var _sprite: Sprite2D = get_node_or_null("Sprite") as Sprite2D


func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 2
	collision_mask = 1
	health.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as Player

	var facing_direction := 0.0
	if _player != null and _player.alive:
		facing_direction = signf(_player.global_position.x - global_position.x)
		velocity.x = facing_direction * SPEED
		if global_position.distance_to(_player.global_position) < CONTACT_RANGE:
			_player.take_damage()
	else:
		velocity.x = 0.0

	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y += GRAVITY * delta

	move_and_slide()

	if _sprite != null:
		_sprite.frame = int(Time.get_ticks_msec() / 150) % 2
		# The grunt art faces left by default.
		_sprite.flip_h = facing_direction > 0.1


func take_damage(amount: int) -> void:
	health.damage(amount)


func _on_died() -> void:
	died.emit(score_value)
	queue_free()
