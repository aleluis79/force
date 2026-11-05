class_name InputSource
extends RefCounted

## Injectable input abstraction for the player.
##
## Core and entity code depend on this interface instead of the global Input
## singleton, which keeps movement deterministic and testable.

func get_move_axis() -> float:
	return 0.0


func was_jump_just_pressed() -> bool:
	return false


func was_jump_just_released() -> bool:
	return false


func is_shoot_pressed() -> bool:
	return false


func was_shoot_just_pressed() -> bool:
	return false


func is_crouch_pressed() -> bool:
	return false


func get_aim_direction(_origin: Vector2, _pointer: Vector2) -> Vector2:
	return Vector2.RIGHT
