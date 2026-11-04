class_name Pow
extends Area2D

## Prisoner rescued by touching the player.

signal rescued

const RESCUE_RANGE := 16.0

var _rescued := false
var _player: Player

@onready var _sprite: Sprite2D = get_node_or_null("Sprite") as Sprite2D


func _ready() -> void:
	add_to_group("pows")
	collision_layer = 4
	collision_mask = 0


func _physics_process(_delta: float) -> void:
	if _rescued:
		return

	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as Player

	if _sprite != null:
		_sprite.frame = int(Time.get_ticks_msec() / 250) % 2

	if _player == null or not _player.alive:
		return

	if global_position.distance_to(_player.global_position) < RESCUE_RANGE:
		_rescued = true
		rescued.emit()
		queue_free()
