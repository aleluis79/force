class_name LocalInputSource
extends InputSource

## InputSource backed by the project's InputMap actions.

const AIM_DEADZONE := 0.2


func get_move_axis() -> float:
	return Input.get_axis("move_left", "move_right")


func was_jump_just_pressed() -> bool:
	return Input.is_action_just_pressed("jump")


func was_jump_just_released() -> bool:
	return Input.is_action_just_released("jump")


func is_shoot_pressed() -> bool:
	return Input.is_action_pressed("shoot")


func was_shoot_just_pressed() -> bool:
	return Input.is_action_just_pressed("shoot")


func get_aim_direction(origin: Vector2, pointer: Vector2) -> Vector2:
	var stick := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if stick.length() > AIM_DEADZONE:
		return stick.normalized()

	var pointer_direction := pointer - origin
	if pointer_direction.length() > 0.001:
		return pointer_direction.normalized()

	return Vector2.RIGHT
