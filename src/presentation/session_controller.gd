class_name SessionController
extends Node

## Presentation-layer adapter between session input and the pure GameSession.

@export var autostart: bool = true

var session: GameSession


func _ready() -> void:
	session = GameSession.new()
	if autostart:
		session.start()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		session.toggle_pause()
	elif event.is_action_pressed("restart"):
		session.restart()
