class_name ScriptedInputSource
extends InputSource

## Deterministic input source used by integration tests.

var move_axis := 0.0
var jump_just_pressed := false
var jump_just_released := false
var aim_direction := Vector2.RIGHT


func get_move_axis() -> float:
	return move_axis


func was_jump_just_pressed() -> bool:
	return jump_just_pressed


func was_jump_just_released() -> bool:
	return jump_just_released


func get_aim_direction(_origin: Vector2, _pointer: Vector2) -> Vector2:
	return aim_direction
