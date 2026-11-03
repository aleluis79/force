extends Node2D

@onready var controller: SessionController = $SessionController
@onready var terrain: DestructibleTerrain = $Terrain
@onready var player: Player = $Player
@onready var state_label: Label = $UI/StateLabel
@onready var lives_label: Label = $UI/LivesLabel
@onready var score_label: Label = $UI/ScoreLabel


func _ready() -> void:
	controller.session.state_changed.connect(_on_state_changed)
	controller.session.lives_changed.connect(_on_lives_changed)
	controller.session.score_changed.connect(_on_score_changed)

	$UI/LoseLifeButton.pressed.connect(_on_lose_life_pressed)
	$UI/AddScoreButton.pressed.connect(_on_add_score_pressed)
	$UI/RestartButton.pressed.connect(_on_restart_pressed)
	$UI/ExplodeButton.pressed.connect(_on_explode_pressed)

	_refresh()


func _refresh() -> void:
	var state_name := str(GameSession.State.find_key(controller.session.state))
	state_label.text = "State: %s" % state_name
	lives_label.text = "Lives: %d" % controller.session.lives
	score_label.text = "Score: %d" % controller.session.score


func _on_state_changed(_previous: int, _current: int) -> void:
	_refresh()


func _on_lives_changed(_lives: int) -> void:
	_refresh()


func _on_score_changed(_score: int) -> void:
	_refresh()


func _on_lose_life_pressed() -> void:
	controller.session.lose_life()


func _on_add_score_pressed() -> void:
	controller.session.add_score(100)


func _on_restart_pressed() -> void:
	controller.session.restart()


func _on_explode_pressed() -> void:
	terrain.explode(player.global_position + Vector2(0, 16), 32.0)
