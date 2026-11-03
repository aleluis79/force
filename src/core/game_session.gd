class_name GameSession
extends RefCounted

## Pure arcade session state machine.
##
## It owns states, lives and score. It has no dependency on the scene tree,
## global input or autoloads so it can be tested and simulated in isolation.

enum State {
	READY,
	PLAYING,
	PAUSED,
	GAME_OVER,
}

const STARTING_LIVES := 3

signal state_changed(previous: int, current: int)
signal lives_changed(lives: int)
signal score_changed(score: int)

var state: int = State.READY
var lives: int = STARTING_LIVES
var score: int = 0


func start() -> void:
	if state != State.READY:
		return
	_set_state(State.PLAYING)


func pause() -> void:
	if state != State.PLAYING:
		return
	_set_state(State.PAUSED)


func resume() -> void:
	if state != State.PAUSED:
		return
	_set_state(State.PLAYING)


func toggle_pause() -> void:
	if state == State.PLAYING:
		pause()
	elif state == State.PAUSED:
		resume()


func is_playing() -> bool:
	return state == State.PLAYING


func is_paused() -> bool:
	return state == State.PAUSED


func is_game_over() -> bool:
	return state == State.GAME_OVER


func lose_life() -> void:
	if state != State.PLAYING:
		return

	lives = maxi(lives - 1, 0)
	lives_changed.emit(lives)

	if lives == 0:
		_set_state(State.GAME_OVER)


func add_score(points: int) -> void:
	if state != State.PLAYING or points <= 0:
		return

	score += points
	score_changed.emit(score)


func restart() -> void:
	lives = STARTING_LIVES
	score = 0
	lives_changed.emit(lives)
	score_changed.emit(score)
	_set_state(State.PLAYING)


func _set_state(next: int) -> void:
	if state == next:
		return
	var previous := state
	state = next
	state_changed.emit(previous, next)
