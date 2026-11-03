extends GutTest

const PLAYER_START := Vector2(80, 200)
const GROUND_POSITION := Vector2(240, 250)
const GROUND_SIZE := Vector2(480, 32)
const PLAYER_SIZE := Vector2(12, 28)


func test_player_lands_on_the_ground() -> void:
	var setup := _make_setup()
	var player: Player = setup.player

	await _wait_physics_frames(60)

	assert_true(player.is_on_floor(), "player must land on the ground")


func test_player_moves_with_injected_input() -> void:
	var setup := _make_setup()
	var player: Player = setup.player
	var input: ScriptedInputSource = setup.input

	await _wait_physics_frames(60)
	input.move_axis = 1.0
	var start_x := player.global_position.x

	await _wait_physics_frames(30)

	assert_gt(player.global_position.x, start_x + 1.0, "player must move to the right")


func test_player_jumps_with_injected_input() -> void:
	var setup := _make_setup()
	var player: Player = setup.player
	var input: ScriptedInputSource = setup.input

	await _wait_physics_frames(60)
	assert_true(player.is_on_floor(), "player must be grounded before jumping")

	input.jump_just_pressed = true
	await get_tree().physics_frame
	input.jump_just_pressed = false

	assert_lt(player.velocity.y, 0.0, "player must move upwards after jumping")


func test_player_aim_comes_from_the_input_source() -> void:
	var setup := _make_setup()
	var player: Player = setup.player
	var input: ScriptedInputSource = setup.input

	input.aim_direction = Vector2.UP
	await _wait_physics_frames(2)

	assert_eq(player.aim_direction, Vector2.UP)


func _make_setup() -> Dictionary:
	var ground := StaticBody2D.new()
	ground.position = GROUND_POSITION
	var ground_shape := CollisionShape2D.new()
	var ground_rect := RectangleShape2D.new()
	ground_rect.size = GROUND_SIZE
	ground_shape.shape = ground_rect
	ground.add_child(ground_shape)
	add_child_autofree(ground)

	var input := ScriptedInputSource.new()
	var player := Player.new()
	player.position = PLAYER_START
	player.input_source = input
	var player_shape := CollisionShape2D.new()
	var player_rect := RectangleShape2D.new()
	player_rect.size = PLAYER_SIZE
	player_shape.shape = player_rect
	player.add_child(player_shape)
	add_child_autoqfree(player)

	return {"player": player, "input": input}


func _wait_physics_frames(count: int) -> void:
	for index in count:
		await get_tree().physics_frame
