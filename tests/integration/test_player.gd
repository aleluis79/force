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
	var packed := load("res://scenes/player.tscn") as PackedScene
	var player := packed.instantiate() as Player
	player.position = PLAYER_START
	player.input_source = input
	add_child_autoqfree(player)

	return {"player": player, "input": input}


func _wait_physics_frames(count: int) -> void:
	for index in count:
		await get_tree().physics_frame


func test_player_dies_once_and_emits_signal() -> void:
	var setup := _make_setup()
	var player: Player = setup.player
	watch_signals(player)

	player.take_damage()
	assert_false(player.alive)
	assert_false(player.visible)
	assert_signal_emit_count(player, "died", 1)

	player.take_damage()
	assert_signal_emit_count(player, "died", 1, "death must only be emitted once")


func test_player_respawn_restores_state_and_grants_invulnerability() -> void:
	var setup := _make_setup()
	var player: Player = setup.player
	player.take_damage()

	player.respawn(Vector2(50, 50))

	assert_true(player.alive)
	assert_true(player.visible)
	assert_true(player.invulnerable)
	assert_eq(player.global_position, Vector2(50, 50))

	player.take_damage()
	assert_true(player.alive, "invulnerability must ignore damage")


func test_player_faces_the_movement_direction() -> void:
	var setup := _make_setup()
	var player: Player = setup.player
	var input: ScriptedInputSource = setup.input
	var sprite := player.get_node("Sprite") as Sprite2D
	player.aim_direction = Vector2.RIGHT

	input.move_axis = -1.0
	player._update_sprite()
	assert_true(sprite.flip_h, "moving left must flip the player sprite")

	input.move_axis = 1.0
	player._update_sprite()
	assert_false(sprite.flip_h, "moving right must face right")


func test_player_faces_the_aim_when_idle() -> void:
	var setup := _make_setup()
	var player: Player = setup.player
	var input: ScriptedInputSource = setup.input
	var sprite := player.get_node("Sprite") as Sprite2D
	input.move_axis = 0.0
	player.velocity = Vector2.ZERO
	player.aim_direction = Vector2.LEFT

	player._update_sprite()

	assert_true(sprite.flip_h, "idle player must face the aim direction")
