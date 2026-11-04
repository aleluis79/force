class_name PlayerCamera
extends Camera2D

## Follows the player through the node hierarchy, adds aim look-ahead and shake.

@export var look_ahead_distance := 32.0
@export var follow_speed := 8.0

var target_offset := Vector2.ZERO

var _base_position := Vector2.ZERO
var _shake_time := 0.0
var _shake_strength := 0.0


func update_look_ahead(aim: Vector2) -> void:
	if aim.length() > 0.001:
		target_offset = aim.normalized() * look_ahead_distance
	else:
		target_offset = Vector2.ZERO


func shake(strength: float, duration: float = 0.15) -> void:
	_shake_strength = maxf(_shake_strength, strength)
	_shake_time = maxf(_shake_time, duration)


func is_shaking() -> bool:
	return _shake_time > 0.0


func _process(delta: float) -> void:
	_base_position = _base_position.lerp(
		target_offset,
		clampf(follow_speed * delta, 0.0, 1.0)
	)

	var shake_offset := Vector2.ZERO
	if _shake_time > 0.0:
		_shake_time = maxf(_shake_time - delta, 0.0)
		shake_offset = Vector2(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		) * _shake_strength
		_shake_strength = maxf(_shake_strength - delta * 20.0, 0.0)

	position = _base_position + shake_offset


func _exit_tree() -> void:
	enabled = false
