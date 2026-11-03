class_name PlayerMotion
extends RefCounted

## Pure player movement model.
##
## The node layer feeds it input and collision state, then copies the returned
## velocity into a CharacterBody2D. No Input, Node or scene-tree dependency.

const MAX_SPEED := 120.0
const ACCELERATION := 900.0
const DECELERATION := 1200.0
const GRAVITY := 900.0
const MAX_FALL_SPEED := 400.0
const JUMP_VELOCITY := -300.0
const JUMP_CUT_MULTIPLIER := 0.4
const COYOTE_TIME := 0.1
const JUMP_BUFFER_TIME := 0.1

var velocity := Vector2.ZERO
var grounded := false

var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0


func reset() -> void:
	velocity = Vector2.ZERO
	grounded = false
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0


func tick(
	delta: float,
	move_axis: float,
	jump_just_pressed: bool,
	jump_just_released: bool,
	grounded_now: bool
) -> Vector2:
	grounded = grounded_now

	if grounded:
		_coyote_timer = COYOTE_TIME
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	if jump_just_pressed:
		_jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)

	var axis := clampf(move_axis, -1.0, 1.0)
	var target_speed := axis * MAX_SPEED
	var acceleration := ACCELERATION if not is_zero_approx(axis) else DECELERATION
	velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
	velocity.x = clampf(velocity.x, -MAX_SPEED, MAX_SPEED)

	if grounded:
		velocity.y = 0.0

	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0

	if jump_just_released and velocity.y < 0.0:
		velocity.y *= JUMP_CUT_MULTIPLIER

	if not grounded:
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)

	return velocity
