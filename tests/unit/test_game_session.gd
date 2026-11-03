extends GutTest


func test_new_session_starts_ready_with_three_lives_and_zero_score() -> void:
	var session := GameSession.new()

	assert_eq(session.state, GameSession.State.READY, "new session must start in READY")
	assert_eq(session.lives, GameSession.STARTING_LIVES, "new session must start with 3 lives")
	assert_eq(session.lives, 3, "starting lives must be 3")
	assert_eq(session.score, 0, "new session must start with 0 score")


func test_start_moves_ready_to_playing() -> void:
	var session := GameSession.new()

	session.start()

	assert_eq(session.state, GameSession.State.PLAYING)
	assert_true(session.is_playing())


func test_start_is_ignored_when_already_playing() -> void:
	var session := GameSession.new()
	session.start()

	session.start()

	assert_eq(session.state, GameSession.State.PLAYING)
	assert_eq(session.lives, 3)
	assert_eq(session.score, 0)


func test_pause_moves_playing_to_paused() -> void:
	var session := GameSession.new()
	session.start()

	session.pause()

	assert_eq(session.state, GameSession.State.PAUSED)
	assert_true(session.is_paused())


func test_resume_moves_paused_to_playing() -> void:
	var session := GameSession.new()
	session.start()
	session.pause()

	session.resume()

	assert_eq(session.state, GameSession.State.PLAYING)
	assert_true(session.is_playing())


func test_pause_is_ignored_in_ready() -> void:
	var session := GameSession.new()

	session.pause()

	assert_eq(session.state, GameSession.State.READY)


func test_resume_is_ignored_when_not_paused() -> void:
	var session := GameSession.new()
	session.start()

	session.resume()

	assert_eq(session.state, GameSession.State.PLAYING)


func test_toggle_pause_twice_returns_to_playing() -> void:
	var session := GameSession.new()
	session.start()

	session.toggle_pause()
	assert_eq(session.state, GameSession.State.PAUSED)

	session.toggle_pause()
	assert_eq(session.state, GameSession.State.PLAYING)


func test_toggle_pause_is_ignored_in_ready() -> void:
	var session := GameSession.new()

	session.toggle_pause()

	assert_eq(session.state, GameSession.State.READY)


func test_state_changed_signal_is_emitted_on_start() -> void:
	var session := GameSession.new()
	watch_signals(session)

	session.start()

	assert_signal_emitted(session, "state_changed")
	assert_signal_emit_count(session, "state_changed", 1)


func test_lose_life_decrements_and_keeps_playing() -> void:
	var session := GameSession.new()
	session.start()

	session.lose_life()

	assert_eq(session.lives, 2)
	assert_eq(session.state, GameSession.State.PLAYING)


func test_losing_last_life_enters_game_over() -> void:
	var session := GameSession.new()
	session.start()
	session.lose_life()
	session.lose_life()

	session.lose_life()

	assert_eq(session.lives, 0)
	assert_eq(session.state, GameSession.State.GAME_OVER)
	assert_true(session.is_game_over())


func test_lose_life_is_ignored_when_not_playing() -> void:
	var session := GameSession.new()

	session.lose_life()
	assert_eq(session.lives, 3)
	assert_eq(session.state, GameSession.State.READY)

	session.start()
	session.pause()
	session.lose_life()
	assert_eq(session.lives, 3)
	assert_eq(session.state, GameSession.State.PAUSED)


func test_lives_never_go_negative() -> void:
	var session := GameSession.new()
	session.start()
	session.lose_life()
	session.lose_life()
	session.lose_life()

	session.lose_life()

	assert_eq(session.lives, 0)
	assert_eq(session.state, GameSession.State.GAME_OVER)


func test_add_score_increments_while_playing() -> void:
	var session := GameSession.new()
	session.start()

	session.add_score(100)

	assert_eq(session.score, 100)


func test_add_score_is_ignored_when_not_playing() -> void:
	var session := GameSession.new()

	session.add_score(100)
	assert_eq(session.score, 0)

	session.start()
	session.pause()
	session.add_score(100)
	assert_eq(session.score, 0)


func test_add_score_ignores_zero_and_negative_values() -> void:
	var session := GameSession.new()
	session.start()

	session.add_score(0)
	session.add_score(-50)

	assert_eq(session.score, 0)


func test_score_is_kept_after_game_over() -> void:
	var session := GameSession.new()
	session.start()
	session.add_score(250)
	session.lose_life()
	session.lose_life()
	session.lose_life()

	assert_eq(session.state, GameSession.State.GAME_OVER)
	assert_eq(session.score, 250)


func test_restart_from_game_over_resets_the_run() -> void:
	var session := GameSession.new()
	session.start()
	session.add_score(250)
	session.lose_life()
	session.lose_life()
	session.lose_life()

	session.restart()

	assert_eq(session.state, GameSession.State.PLAYING)
	assert_eq(session.lives, 3)
	assert_eq(session.score, 0)


func test_restart_from_playing_resets_the_run() -> void:
	var session := GameSession.new()
	session.start()
	session.add_score(50)
	session.lose_life()

	session.restart()

	assert_eq(session.state, GameSession.State.PLAYING)
	assert_eq(session.lives, 3)
	assert_eq(session.score, 0)


func test_restart_from_paused_resets_the_run() -> void:
	var session := GameSession.new()
	session.start()
	session.pause()

	session.restart()

	assert_eq(session.state, GameSession.State.PLAYING)
	assert_eq(session.lives, 3)
	assert_eq(session.score, 0)


func test_lives_and_score_signals_are_emitted() -> void:
	var session := GameSession.new()
	session.start()
	watch_signals(session)

	session.lose_life()
	session.add_score(75)

	assert_signal_emitted_with_parameters(session, "lives_changed", [2])
	assert_signal_emitted_with_parameters(session, "score_changed", [75])


func test_invalid_transitions_do_not_emit_state_changed() -> void:
	var session := GameSession.new()
	watch_signals(session)

	session.pause()
	session.resume()
	session.toggle_pause()
	session.lose_life()
	session.add_score(10)

	assert_signal_emit_count(session, "state_changed", 0)
	assert_signal_emit_count(session, "lives_changed", 0)
	assert_signal_emit_count(session, "score_changed", 0)
