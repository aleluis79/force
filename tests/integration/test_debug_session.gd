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


func test_debug_scene_contains_player_ground_and_platform() -> void:
	var scene = await _instantiate_debug_scene()

	assert_not_null(scene.get_node_or_null("Player"), "debug scene must include the player")
	assert_not_null(scene.get_node_or_null("Ground"), "debug scene must include the ground")
	assert_not_null(scene.get_node_or_null("Platform"), "debug scene must include the platform")


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
	add_child_autofree(scene)
	await get_tree().process_frame
	return scene


func _key_event(keycode: int) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	event.pressed = true
	return event
