extends GutTest

const LEVEL_SCENE := "res://scenes/level_01.tscn"


func after_each() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0


func test_level_loads_with_content() -> void:
	var level = await _instantiate_level()

	assert_eq(level.terrain.width, 120, "level terrain must be 960 px wide")
	assert_not_null(level.player, "level must include the player")
	assert_not_null(level.exit, "level must include an exit")
	assert_eq(_count_group_in_level(level, "enemies"), 5)
	assert_eq(_count_group_in_level(level, "pows"), 2)
	assert_eq(level.lives_label.text, "Lives: 3")
	assert_eq(level.score_label.text, "Score: 0")
	assert_eq(level.weapon_label.text, "Weapon: Rifle")


func test_player_lands_on_the_level_ground() -> void:
	var level = await _instantiate_level()

	await _wait_physics_frames(60)

	assert_true(level.player.is_on_floor(), "player must land on the level terrain")


func test_rescue_rewards_life_score_and_checkpoint() -> void:
	var level = await _instantiate_level()
	var pow := level.get_node("Pow1") as Pow
	var pow_position := pow.global_position

	level.player.global_position = pow_position
	await _wait_physics_frames(10)

	assert_eq(level.session_controller.session.lives, 4)
	assert_true(level.session_controller.session.score >= 500)
	assert_eq(level.checkpoint, pow_position)
	assert_eq(level.lives_label.text, "Lives: 4")


func test_player_death_loses_life_and_respawns() -> void:
	var level = await _instantiate_level()
	await _wait_physics_frames(60)
	var lives_before: int = level.session_controller.session.lives

	level.player.take_damage()
	await _wait_physics_frames(2)

	assert_eq(level.session_controller.session.lives, lives_before - 1)
	assert_false(level.player.alive)

	await get_tree().create_timer(0.8).timeout

	assert_true(level.player.alive, "player must respawn after a short delay")
	assert_almost_eq(level.player.global_position.x, level.checkpoint.x, 1.0)


func test_enemy_death_adds_score() -> void:
	var level = await _instantiate_level()
	var grunt := level.get_node("Grunt1") as Grunt
	var score_before: int = level.session_controller.session.score

	grunt.take_damage(999)
	await _wait_physics_frames(2)

	assert_true(
		level.session_controller.session.score >= score_before + 100,
		"enemy death must add score"
	)


func test_reaching_the_exit_wins() -> void:
	var level = await _instantiate_level()

	level.player.global_position = level.exit.global_position
	await _wait_physics_frames(2)

	assert_true(level.session_controller.session.is_victory())
	assert_true(level.message_label.text.contains("VICTORY"))


func test_game_over_updates_message() -> void:
	var level = await _instantiate_level()
	var session: GameSession = level.session_controller.session

	session.lose_life()
	session.lose_life()
	session.lose_life()

	assert_true(session.is_game_over())
	assert_true(level.message_label.text.contains("GAME OVER"))


func test_pause_pauses_tree_and_shows_message() -> void:
	var level = await _instantiate_level()
	var session: GameSession = level.session_controller.session

	level.session_controller._unhandled_input(_key_event(KEY_ESCAPE))
	assert_true(session.is_paused())
	assert_true(get_tree().paused)
	assert_true(level.message_label.text.contains("PAUSED"))

	level.session_controller._unhandled_input(_key_event(KEY_ESCAPE))
	assert_true(session.is_playing())
	assert_false(get_tree().paused)


func test_restart_from_game_over_resets_session() -> void:
	var level = await _instantiate_level()
	var session: GameSession = level.session_controller.session
	session.lose_life()
	session.lose_life()
	session.lose_life()

	session.restart()

	assert_eq(session.state, GameSession.State.PLAYING)
	assert_eq(session.lives, 3)
	assert_eq(session.score, 0)


func _instantiate_level() -> Node:
	var packed := load(LEVEL_SCENE) as PackedScene
	assert_not_null(packed, "level scene must load")
	var level := packed.instantiate()
	add_child_autoqfree(level)
	await get_tree().process_frame
	return level


func _count_group_in_level(level: Node, group: String) -> int:
	var count := 0
	for node in get_tree().get_nodes_in_group(group):
		if level.is_ancestor_of(node):
			count += 1
	return count


func _wait_physics_frames(count: int) -> void:
	for index in count:
		await get_tree().physics_frame


func _key_event(keycode: int) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	event.pressed = true
	return event
