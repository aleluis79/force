class_name PlayerCamera
extends Camera2D

## Follows the player through the node hierarchy and adds aim look-ahead.

@export var look_ahead_distance := 32.0
@export var follow_speed := 8.0

var target_offset := Vector2.ZERO


func update_look_ahead(aim: Vector2) -> void:
	if aim.length() > 0.001:
		target_offset = aim.normalized() * look_ahead_distance
	else:
		target_offset = Vector2.ZERO


func _process(delta: float) -> void:
	position = position.lerp(target_offset, clampf(follow_speed * delta, 0.0, 1.0))


func _exit_tree() -> void:
	enabled = false
