extends Node2D

## Playable level controller: session, enemies, rescues, death and victory.

const SPAWN_POSITION := Vector2(80, 200)
const FALL_LIMIT := 320.0
const EXIT_RANGE := 20.0

@onready var session_controller: SessionController = $SessionController
@onready var hit_stop: Node = $HitStop
@onready var terrain: DestructibleTerrain = $Terrain
@onready var player: Player = $Player
@onready var exit: Node2D = $Exit
@onready var lives_label: Label = $UI/LivesLabel
@onready var score_label: Label = $UI/ScoreLabel
@onready var weapon_label: Label = $UI/WeaponLabel
@onready var message_label: Label = $UI/MessageLabel

var checkpoint := SPAWN_POSITION
var _session: GameSession


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	session_controller.process_mode = Node.PROCESS_MODE_ALWAYS
	$UI.process_mode = Node.PROCESS_MODE_ALWAYS
	var ui_theme := load("res://assets/theme/game_theme.tres") as Theme
	for child in $UI.get_children():
		if child is Control:
			child.theme = ui_theme

	terrain.rebuild(240, 34, 6, [
		Rect2i(20, 22, 14, 2),
		Rect2i(45, 18, 14, 2),
		Rect2i(70, 22, 16, 2),
		Rect2i(95, 16, 14, 2),
		Rect2i(120, 20, 18, 2),
		Rect2i(150, 16, 16, 2),
		Rect2i(180, 22, 14, 2),
		Rect2i(210, 18, 16, 2),
	])

	var camera := player.get_node_or_null("Camera2D") as Camera2D
	if camera != null:
		camera.limit_right = terrain.width * DestructibleTerrain.TILE_SIZE

	_session = session_controller.session
	_session.state_changed.connect(_on_state_changed)
	_session.lives_changed.connect(_on_lives_changed)
	_session.score_changed.connect(_on_score_changed)
	player.died.connect(_on_player_died)
	player.weapon_changed.connect(_on_weapon_changed)
	player.bullet_pool.hit_confirmed.connect(_on_hit_confirmed)
	terrain.terrain_destroyed.connect(_on_terrain_destroyed)

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_signal("died"):
			enemy.died.connect(_on_enemy_died)

	for pow in get_tree().get_nodes_in_group("pows"):
		if pow.has_signal("rescued"):
			pow.rescued.connect(_on_pow_rescued.bind(pow))

	_on_lives_changed(_session.lives)
	_on_score_changed(_session.score)
	_on_weapon_changed(player.weapon_state.stats)
	_update_message()
	AudioManager.play_music()


func _exit_tree() -> void:
	AudioManager.stop_music()


func _physics_process(_delta: float) -> void:
	if not _session.is_playing():
		return

	if player.alive and player.global_position.y > FALL_LIMIT:
		player.take_damage()

	if player.alive and player.global_position.distance_to(exit.global_position) < EXIT_RANGE:
		_session.win()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().paused = false
		get_tree().reload_current_scene()


func _on_state_changed(_previous: int, current: int) -> void:
	if current == GameSession.State.VICTORY:
		AudioManager.play_sfx("victory")
	get_tree().paused = _session.is_paused()
	var active := _session.is_playing()
	player.set_physics_process(active)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy):
			enemy.set_physics_process(active)
	_update_message()


func _on_player_died() -> void:
	if not _session.is_playing():
		return

	AudioManager.play_sfx("death")
	_session.lose_life()
	if _session.is_game_over():
		return

	await get_tree().create_timer(0.6).timeout
	if _session.is_playing():
		player.respawn(checkpoint)


func _on_enemy_died(points: int) -> void:
	AudioManager.play_sfx("hit")
	_session.add_score(points)


func _on_pow_rescued(pow: Node) -> void:
	AudioManager.play_sfx("pickup")
	checkpoint = pow.global_position
	_session.add_life()
	_session.add_score(500)


func _on_lives_changed(lives: int) -> void:
	lives_label.text = "Lives: %d" % lives


func _on_score_changed(score: int) -> void:
	score_label.text = "Score: %d" % score


func _on_weapon_changed(stats: WeaponStats) -> void:
	weapon_label.text = "Weapon: %s" % stats.id.capitalize()


func _on_hit_confirmed(_position: Vector2, _target: Node) -> void:
	AudioManager.play_sfx("hit")
	hit_stop.trigger(0.04)
	var camera := player.get_node_or_null("Camera2D") as PlayerCamera
	if camera != null:
		camera.shake(3.0)


func _on_terrain_destroyed(_cells: Array, _position: Vector2) -> void:
	var camera := player.get_node_or_null("Camera2D") as PlayerCamera
	if camera != null:
		camera.shake(2.0)


func _update_message() -> void:
	match _session.state:
		GameSession.State.PAUSED:
			message_label.text = "PAUSED — Esc to resume"
		GameSession.State.GAME_OVER:
			message_label.text = "GAME OVER — R to restart"
		GameSession.State.VICTORY:
			message_label.text = "VICTORY — R to restart"
		_:
			message_label.text = ""
