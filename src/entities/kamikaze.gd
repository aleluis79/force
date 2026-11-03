class_name Kamikaze
extends Area2D

## Flying enemy that homes toward the player and explodes on contact.

signal died(points: int)

const SPEED := 70.0
const CONTACT_RANGE := 14.0

@export var score_value := 150

var health := Health.new(10)
var _player: Player
var _dead := false


func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 2
	collision_mask = 0
	health.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if _dead:
		return

	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as Player

	if _player == null or not _player.alive:
		return

	var direction := (_player.global_position - global_position).normalized()
	global_position += direction * SPEED * delta

	if global_position.distance_to(_player.global_position) < CONTACT_RANGE:
		_player.take_damage()
		_on_died()


func take_damage(amount: int) -> void:
	health.damage(amount)


func _on_died() -> void:
	if _dead:
		return
	_dead = true
	died.emit(score_value)
	queue_free()
