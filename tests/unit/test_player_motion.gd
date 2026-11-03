extends GutTest


func test_accelerates_to_the_right() -> void:
	var motion := PlayerMotion.new()

	var velocity := motion.tick(0.1, 1.0, false, false, true)

	assert_gt(velocity.x, 0.0, "right input must accelerate to the right")
	assert_true(velocity.x <= PlayerMotion.MAX_SPEED, "horizontal speed must respect the cap")


func test_accelerates_to_the_left() -> void:
	var motion := PlayerMotion.new()

	var velocity := motion.tick(0.1, -1.0, false, false, true)

	assert_lt(velocity.x, 0.0, "left input must accelerate to the left")


func test_reaches_max_speed_but_does_not_exceed_it() -> void:
	var motion := PlayerMotion.new()
	var velocity := Vector2.ZERO

	for index in 120:
		velocity = motion.tick(0.016, 1.0, false, false, true)

	assert_almost_eq(velocity.x, PlayerMotion.MAX_SPEED, 0.001)
	assert_true(velocity.x <= PlayerMotion.MAX_SPEED)


func test_decelerates_to_stop_without_input() -> void:
	var motion := PlayerMotion.new()

	for index in 120:
		motion.tick(0.016, 1.0, false, false, true)

	var velocity := Vector2.ZERO
	for index in 120:
		velocity = motion.tick(0.016, 0.0, false, false, true)

	assert_almost_eq(velocity.x, 0.0, 0.001)


func test_gravity_increases_fall_speed() -> void:
	var motion := PlayerMotion.new()

	var first := motion.tick(0.1, 0.0, false, false, false)
	var second := motion.tick(0.1, 0.0, false, false, false)

	assert_gt(first.y, 0.0, "airborne motion must fall")
	assert_gt(second.y, first.y, "fall speed must increase over time")


func test_fall_speed_is_capped() -> void:
	var motion := PlayerMotion.new()
	var velocity := Vector2.ZERO

	for index in 300:
		velocity = motion.tick(0.016, 0.0, false, false, false)

	assert_almost_eq(velocity.y, PlayerMotion.MAX_FALL_SPEED, 0.001)
	assert_true(velocity.y <= PlayerMotion.MAX_FALL_SPEED)


func test_jump_from_ground_sets_negative_vertical_velocity() -> void:
	var motion := PlayerMotion.new()

	var velocity := motion.tick(0.016, 0.0, true, false, true)

	assert_lt(velocity.y, 0.0, "jumping from the ground must move upwards")


func test_no_double_jump_while_airborne() -> void:
	var with_jump := PlayerMotion.new()
	with_jump.tick(0.016, 0.0, true, false, true)
	var with_jump_velocity := with_jump.tick(0.2, 0.0, true, false, false)

	var without_jump := PlayerMotion.new()
	without_jump.tick(0.016, 0.0, true, false, true)
	var without_jump_velocity := without_jump.tick(0.2, 0.0, false, false, false)

	assert_almost_eq(with_jump_velocity.y, without_jump_velocity.y, 0.001)


func test_releasing_jump_cuts_upward_velocity() -> void:
	var cut := PlayerMotion.new()
	cut.tick(0.016, 0.0, true, false, true)
	var cut_velocity := cut.tick(0.016, 0.0, false, true, false)

	var full := PlayerMotion.new()
	full.tick(0.016, 0.0, true, false, true)
	var full_velocity := full.tick(0.016, 0.0, false, false, false)

	assert_gt(cut_velocity.y, full_velocity.y, "releasing jump must reduce upward speed")
	assert_lt(cut_velocity.y, 0.0, "the cut jump must still be ascending")


func test_coyote_time_allows_a_late_jump() -> void:
	var motion := PlayerMotion.new()
	motion.tick(0.016, 0.0, false, false, true)
	motion.tick(0.05, 0.0, false, false, false)

	var velocity := motion.tick(0.016, 0.0, true, false, false)

	assert_lt(velocity.y, 0.0, "jump within coyote time must execute")


func test_coyote_time_expires() -> void:
	var motion := PlayerMotion.new()
	motion.tick(0.016, 0.0, false, false, true)
	motion.tick(0.2, 0.0, false, false, false)

	var velocity := motion.tick(0.016, 0.0, true, false, false)

	assert_gt(velocity.y, 0.0, "jump after coyote time must not execute")


func test_jump_buffer_executes_on_landing() -> void:
	var motion := PlayerMotion.new()
	motion.tick(0.016, 0.0, true, false, false)

	var velocity := motion.tick(0.016, 0.0, false, false, true)

	assert_lt(velocity.y, 0.0, "buffered jump must execute on landing")


func test_jump_buffer_expires() -> void:
	var motion := PlayerMotion.new()
	motion.tick(0.016, 0.0, true, false, false)
	motion.tick(0.2, 0.0, false, false, false)

	var velocity := motion.tick(0.016, 0.0, false, false, true)

	assert_eq(velocity.y, 0.0, "expired buffered jump must not execute")


func test_reset_clears_movement_state() -> void:
	var motion := PlayerMotion.new()
	motion.tick(0.1, 1.0, true, false, true)

	motion.reset()

	assert_eq(motion.velocity, Vector2.ZERO)
	assert_false(motion.grounded)

	var velocity := motion.tick(0.016, 0.0, false, false, false)
	assert_gt(velocity.y, 0.0, "after reset gravity must start from zero")
