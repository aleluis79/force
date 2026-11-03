extends GutTest


func test_controller_autostarts_the_session() -> void:
	var controller := _make_controller()

	assert_not_null(controller.session, "controller must create a session")
	assert_true(controller.session.is_playing(), "autostart must leave the session PLAYING")


func test_controller_without_autostart_stays_ready() -> void:
	var controller := _make_controller(false)

	assert_eq(controller.session.state, GameSession.State.READY)


func test_pause_event_toggles_the_session() -> void:
	var controller := _make_controller()

	controller._unhandled_input(_key_event(KEY_ESCAPE))
	assert_true(controller.session.is_paused(), "pause event must pause a playing session")

	controller._unhandled_input(_key_event(KEY_ESCAPE))
	assert_true(controller.session.is_playing(), "second pause event must resume the session")


func test_restart_event_resets_the_session() -> void:
	var controller := _make_controller()
	controller.session.add_score(120)
	controller.session.lose_life()
	controller.session.lose_life()

	controller._unhandled_input(_key_event(KEY_R))

	assert_eq(controller.session.state, GameSession.State.PLAYING)
	assert_eq(controller.session.lives, 3)
	assert_eq(controller.session.score, 0)


func _make_controller(autostart: bool = true) -> SessionController:
	var controller := SessionController.new()
	controller.autostart = autostart
	add_child_autofree(controller)
	return controller


func _key_event(keycode: int) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	event.pressed = true
	return event
