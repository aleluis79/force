extends GutTest


func test_base_source_is_neutral() -> void:
	var source := InputSource.new()

	assert_eq(source.get_move_axis(), 0.0)
	assert_false(source.was_jump_just_pressed())
	assert_false(source.was_jump_just_released())
	assert_false(source.is_crouch_pressed())
	assert_eq(source.get_aim_direction(Vector2.ZERO, Vector2.ZERO), Vector2.RIGHT)


func test_local_source_uses_pointer_when_stick_is_idle() -> void:
	var source := LocalInputSource.new()

	var aim := source.get_aim_direction(Vector2(10, 10), Vector2(20, 10))

	assert_almost_eq(aim.x, 1.0, 0.001)
	assert_almost_eq(aim.y, 0.0, 0.001)


func test_local_source_normalizes_pointer_direction() -> void:
	var source := LocalInputSource.new()

	var aim := source.get_aim_direction(Vector2.ZERO, Vector2(3, 4))

	assert_almost_eq(aim.length(), 1.0, 0.001)
	assert_almost_eq(aim.x, 0.6, 0.001)
	assert_almost_eq(aim.y, 0.8, 0.001)


func test_local_source_defaults_right_without_aim_input() -> void:
	var source := LocalInputSource.new()

	var aim := source.get_aim_direction(Vector2(10, 10), Vector2(10, 10))

	assert_eq(aim, Vector2.RIGHT)


func test_local_source_prefers_the_stick_over_the_pointer() -> void:
	var source := LocalInputSource.new()
	Input.action_press("aim_left", 1.0)

	var aim := source.get_aim_direction(Vector2.ZERO, Vector2(100, 0))
	Input.action_release("aim_left")

	assert_lt(aim.x, 0.0, "stick input must override the pointer")


func test_local_source_reads_the_crouch_action() -> void:
	var source := LocalInputSource.new()

	Input.action_press("crouch")
	var pressed := source.is_crouch_pressed()
	Input.action_release("crouch")

	assert_true(pressed)
	assert_false(source.is_crouch_pressed())
