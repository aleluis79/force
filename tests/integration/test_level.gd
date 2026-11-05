extends GutTest

const LEVEL_SCENE := "res://scenes/level_01.tscn"
const MAX_JUMP_RISE := 44.0
const MAX_JUMP_GAP := 56.0


func after_each() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0


func test_level_loads_with_content() -> void:
	var level = await _instantiate_level()

	assert_eq(level.terrain.width, 480, "level terrain must be 3840 px wide")
	assert_not_null(level.player, "level must include the player")
	assert_not_null(level.exit, "level must include an exit")
	assert_true(level.exit.global_position.x > 3700.0, "exit must be at the end of the level")
	assert_gte(_count_group_in_level(level, "enemies"), 30)
	assert_gte(_count_group_in_level(level, "pows"), 8)
	assert_gte(level.platforms.size(), 25)
	assert_eq(level.lives_label.text, "Lives: 3")
	assert_eq(level.score_label.text, "Score: 0")
	assert_eq(level.weapon_label.text, "Weapon: Rifle")
	assert_not_null(level.health_bar, "level must include a health bar")
	assert_almost_eq(level.health_bar.max_value, 100.0, 0.01)
	assert_almost_eq(level.health_bar.value, 100.0, 0.01)
	assert_not_null(level.lives_label.theme, "HUD must use the pixel theme")


func test_level_platforms_are_reachable_from_the_ground() -> void:
	var level = await _instantiate_level()
	var platforms: Array = level.platforms
	var reached: Array[Rect2i] = []
	var pending: Array[Rect2i] = []
	for platform in platforms:
		pending.append(platform)

	var ground_top := float(
		(level.terrain.height - level.terrain.ground_rows) * DestructibleTerrain.TILE_SIZE
	)
	var level_right := float(level.terrain.width * DestructibleTerrain.TILE_SIZE)

	while not pending.is_empty():
		var found := false
		for platform in pending.duplicate():
			var reachable := _can_reach(
				ground_top, 0.0, level_right, platform
			)
			if not reachable:
				for source in reached:
					var source_left := float(source.position.x * DestructibleTerrain.TILE_SIZE)
					var source_right := float(
						(source.position.x + source.size.x) * DestructibleTerrain.TILE_SIZE
					)
					if _can_reach(
						float(source.position.y * DestructibleTerrain.TILE_SIZE),
						source_left,
						source_right,
						platform
					):
						reachable = true
						break
			if reachable:
				reached.append(platform)
				pending.erase(platform)
				found = true
				break
		if not found:
			break

	assert_eq(
		reached.size(),
		platforms.size(),
		"every platform must be reachable from the ground or another platform"
	)


func test_level_platforms_are_solid_and_clear() -> void:
	var level = await _instantiate_level()
	var grid: TerrainGrid = level.terrain.grid

	for platform in level.platforms:
		assert_gte(platform.size.x, 4, "platforms must be wide enough to land on")
		for x in range(platform.position.x, platform.position.x + platform.size.x):
			assert_true(grid.is_solid(Vector2i(x, platform.position.y)), "platform top must be solid")
			assert_false(
				grid.is_solid(Vector2i(x, platform.position.y - 1)),
				"platform must have clear space above"
			)


func test_level_platforms_do_not_overlap() -> void:
	var level = await _instantiate_level()
	var platforms: Array = level.platforms
	var ground := Rect2i(
		0,
		level.terrain.height - level.terrain.ground_rows,
		level.terrain.width,
		level.terrain.ground_rows
	)

	for index in platforms.size():
		assert_false(platforms[index].intersects(ground), "platform must not overlap the ground")
		for other_index in range(index + 1, platforms.size()):
			assert_false(
				platforms[index].intersects(platforms[other_index]),
				"platforms must not overlap each other"
			)


func test_player_lands_on_a_high_platform() -> void:
	var level = await _instantiate_level()
	var platform: Rect2i = level.platforms[2]
	var platform_top := float(platform.position.y * DestructibleTerrain.TILE_SIZE)
	var center_x := float(
		(platform.position.x + platform.size.x * 0.5) * DestructibleTerrain.TILE_SIZE
	)

	level.player.global_position = Vector2(center_x, platform_top - 40.0)
	level.player.velocity = Vector2.ZERO
	await _wait_physics_frames(60)

	assert_true(level.player.is_on_floor(), "player must land on the high platform")
	assert_almost_eq(level.player.global_position.y, platform_top - 14.0, 2.0)


func _can_reach(
	source_top: float,
	source_left: float,
	source_right: float,
	target: Rect2i
) -> bool:
	var target_top := float(target.position.y * DestructibleTerrain.TILE_SIZE)
	var rise := source_top - target_top
	if rise > MAX_JUMP_RISE:
		return false

	var target_left := float(target.position.x * DestructibleTerrain.TILE_SIZE)
	var target_right := float(
		(target.position.x + target.size.x) * DestructibleTerrain.TILE_SIZE
	)
	var gap := 0.0
	if target_left > source_right:
		gap = target_left - source_right
	elif target_right < source_left:
		gap = source_left - target_right

	var allowed_gap := MAX_JUMP_GAP if rise > 0.0 else MAX_JUMP_GAP * 1.4
	return gap <= allowed_gap


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

	level.player.take_damage(level.player.health.max_health)
	await _wait_physics_frames(2)

	assert_eq(level.session_controller.session.lives, lives_before - 1)
	assert_false(level.player.alive)

	await get_tree().create_timer(0.8).timeout

	assert_true(level.player.alive, "player must respawn after a short delay")
	assert_almost_eq(level.player.global_position.x, level.checkpoint.x, 1.0)


func test_health_bar_updates_on_damage_and_respawn() -> void:
	var level = await _instantiate_level()
	var player: Player = level.player

	player.take_damage(25)
	await _wait_physics_frames(2)
	assert_almost_eq(level.health_bar.value, 75.0, 0.01)

	player.respawn(level.checkpoint)
	await _wait_physics_frames(2)
	assert_almost_eq(level.health_bar.value, level.health_bar.max_value, 0.01)


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
