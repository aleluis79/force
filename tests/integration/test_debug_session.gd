extends GutTest

const DEBUG_SCENE := "res://scenes/debug_session.tscn"


func test_debug_scene_starts_playing_with_hud_values() -> void:
	var scene = await _instantiate_debug_scene()

	assert_eq(scene.controller.session.state, GameSession.State.PLAYING)
	assert_eq(scene.state_label.text, "State: PLAYING")
	assert_eq(scene.lives_label.text, "Lives: 3")
	assert_eq(scene.score_label.text, "Score: 0")


func test_lose_life_button_updates_session_and_hud() -> void:
	var scene = await _instantiate_debug_scene()

	scene.get_node("UI/LoseLifeButton").pressed.emit()

	assert_eq(scene.controller.session.lives, 2)
	assert_eq(scene.lives_label.text, "Lives: 2")


func test_add_score_button_updates_session_and_hud() -> void:
	var scene = await _instantiate_debug_scene()

	scene.get_node("UI/AddScoreButton").pressed.emit()

	assert_eq(scene.controller.session.score, 100)
	assert_eq(scene.score_label.text, "Score: 100")


func test_restart_button_resets_session_and_hud() -> void:
	var scene = await _instantiate_debug_scene()
	scene.get_node("UI/LoseLifeButton").pressed.emit()
	scene.get_node("UI/AddScoreButton").pressed.emit()

	scene.get_node("UI/RestartButton").pressed.emit()

	assert_eq(scene.controller.session.state, GameSession.State.PLAYING)
	assert_eq(scene.lives_label.text, "Lives: 3")
	assert_eq(scene.score_label.text, "Score: 0")


func test_pause_event_updates_state_label() -> void:
	var scene = await _instantiate_debug_scene()

	scene.controller._unhandled_input(_key_event(KEY_ESCAPE))

	assert_eq(scene.controller.session.state, GameSession.State.PAUSED)
	assert_eq(scene.state_label.text, "State: PAUSED")


func test_debug_scene_contains_player_and_terrain() -> void:
	var scene = await _instantiate_debug_scene()

	assert_not_null(scene.get_node_or_null("Player"), "debug scene must include the player")
	assert_not_null(scene.get_node_or_null("Terrain"), "debug scene must include destructible terrain")
	assert_not_null(scene.get_node_or_null("TrainingDummy"), "debug scene must include a practice dummy")


func test_weapon_buttons_switch_the_active_weapon() -> void:
	var scene = await _instantiate_debug_scene()

	scene.get_node("UI/ShotgunButton").pressed.emit()
	assert_eq(scene.player.weapon_state.stats.id, "shotgun")

	scene.get_node("UI/RifleButton").pressed.emit()
	assert_eq(scene.player.weapon_state.stats.id, "rifle")


func test_explode_button_removes_terrain() -> void:
	var scene = await _instantiate_debug_scene()
	var terrain := scene.get_node("Terrain") as DestructibleTerrain
	assert_not_null(terrain, "debug scene must expose a DestructibleTerrain node")
	var before := terrain.get_solid_cell_count()

	scene.get_node("UI/ExplodeButton").pressed.emit()

	assert_lt(terrain.get_solid_cell_count(), before, "explode button must destroy terrain")


func test_player_lands_on_ground_in_debug_scene() -> void:
	var scene = await _instantiate_debug_scene()
	var player := scene.get_node("Player") as Player
	assert_not_null(player, "debug scene must expose a Player node")

	for index in 60:
		await get_tree().physics_frame

	assert_true(player.is_on_floor(), "player must land on the debug scene ground")


func _instantiate_debug_scene() -> Node:
	var packed := load(DEBUG_SCENE) as PackedScene
	assert_not_null(packed, "debug session scene must load")
	var scene := packed.instantiate()
	add_child_autoqfree(scene)
	await get_tree().process_frame
	return scene


func _key_event(keycode: int) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	event.pressed = true
	return event
