extends Node2D

## Playable level controller: session, enemies, rescues, death and victory.

const SPAWN_POSITION := Vector2(80, 200)
const FALL_LIMIT := 320.0
const EXIT_RANGE := 20.0
const LEVEL_WIDTH := 480
const LEVEL_HEIGHT := 34
const GROUND_ROWS := 6
const PLATFORM_START_X := 20
const PLATFORM_STEP := 16
const PLATFORM_WIDTH := 10
const PLATFORM_ROWS: Array[int] = [24, 20, 16, 20, 24]
const GRUNT_SCENE := preload("res://scenes/grunt.tscn")
const KAMIKAZE_SCENE := preload("res://scenes/kamikaze.tscn")
const POW_SCENE := preload("res://scenes/pow.tscn")
const GROUND_GRUNT_X: Array[float] = [
	300, 560, 820, 1080, 1340, 1600, 1860, 2120, 2380, 2640, 2900, 3160, 3420, 3660,
]
const KAMIKAZE_SPAWNS: Array[Vector2] = [
	Vector2(500, 80),
	Vector2(780, 120),
	Vector2(1060, 150),
	Vector2(1340, 100),
	Vector2(1620, 140),
	Vector2(1900, 90),
	Vector2(2180, 130),
	Vector2(2460, 160),
	Vector2(2740, 110),
	Vector2(3020, 150),
	Vector2(3300, 100),
	Vector2(3580, 140),
]
const POW_X: Array[float] = [380, 820, 1260, 1700, 2140, 2580, 3020, 3460]
const POW_Y := 210.0

@onready var session_controller: SessionController = $SessionController
@onready var hit_stop: Node = $HitStop
@onready var terrain: DestructibleTerrain = $Terrain
@onready var player: Player = $Player
@onready var exit: Node2D = $Exit
@onready var lives_label: Label = $UI/LivesLabel
@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var score_label: Label = $UI/ScoreLabel
@onready var weapon_label: Label = $UI/WeaponLabel
@onready var message_label: Label = $UI/MessageLabel

var checkpoint := SPAWN_POSITION
var platforms: Array[Rect2i] = []
var _session: GameSession
var _last_health := -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	session_controller.process_mode = Node.PROCESS_MODE_ALWAYS
	$UI.process_mode = Node.PROCESS_MODE_ALWAYS
	var ui_theme := load("res://assets/theme/game_theme.tres") as Theme
	for child in $UI.get_children():
		if child is Control:
			child.theme = ui_theme

	_build_platforms()
	terrain.rebuild(LEVEL_WIDTH, LEVEL_HEIGHT, GROUND_ROWS, platforms)
	_spawn_level_entities()
	exit.global_position = Vector2(LEVEL_WIDTH * DestructibleTerrain.TILE_SIZE - 56, 200)

	var camera := player.get_node_or_null("Camera2D") as Camera2D
	if camera != null:
		camera.limit_right = terrain.width * DestructibleTerrain.TILE_SIZE

	_session = session_controller.session
	_session.state_changed.connect(_on_state_changed)
	_session.lives_changed.connect(_on_lives_changed)
	_session.score_changed.connect(_on_score_changed)
	player.died.connect(_on_player_died)
	player.weapon_changed.connect(_on_weapon_changed)
	player.health_changed.connect(_on_health_changed)
	player.bullet_pool.hit_confirmed.connect(_on_hit_confirmed)
	terrain.terrain_destroyed.connect(_on_terrain_destroyed)

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_signal("died"):
			enemy.died.connect(_on_enemy_died)

	for pow in get_tree().get_nodes_in_group("pows"):
		if pow.has_signal("rescued"):
			pow.rescued.connect(_on_pow_rescued.bind(pow))

	_on_lives_changed(_session.lives)
	_on_health_changed(player.health.current, player.health.max_health)
	_on_score_changed(_session.score)
	_on_weapon_changed(player.weapon_state.stats)
	_update_message()
	AudioManager.play_music()


func _exit_tree() -> void:
	AudioManager.stop_music()


func _build_platforms() -> void:
	platforms.clear()
	var index := 0
	for x in range(PLATFORM_START_X, LEVEL_WIDTH - PLATFORM_WIDTH - 2, PLATFORM_STEP):
		platforms.append(Rect2i(x, PLATFORM_ROWS[index % PLATFORM_ROWS.size()], PLATFORM_WIDTH, 2))
		index += 1


func _spawn_level_entities() -> void:
	var ground_y := float((LEVEL_HEIGHT - GROUND_ROWS) * DestructibleTerrain.TILE_SIZE) - 12.0
	var grunt_index := 1
	for x in GROUND_GRUNT_X:
		_spawn_enemy(GRUNT_SCENE, "Grunt", grunt_index, Vector2(x, ground_y))
		grunt_index += 1

	for platform_index in platforms.size():
		if platform_index % 2 != 0:
			continue
		var platform := platforms[platform_index]
		var position := Vector2(
			(platform.position.x + platform.size.x * 0.5) * DestructibleTerrain.TILE_SIZE,
			platform.position.y * DestructibleTerrain.TILE_SIZE - 12.0
		)
		_spawn_enemy(GRUNT_SCENE, "Grunt", grunt_index, position)
		grunt_index += 1

	var kamikaze_index := 1
	for position in KAMIKAZE_SPAWNS:
		_spawn_enemy(KAMIKAZE_SCENE, "Kamikaze", kamikaze_index, position)
		kamikaze_index += 1

	for index in POW_X.size():
		var pow := POW_SCENE.instantiate()
		pow.name = "Pow%d" % (index + 1)
		pow.position = Vector2(POW_X[index], POW_Y)
		add_child(pow)


func _spawn_enemy(scene: PackedScene, prefix: String, index: int, position: Vector2) -> void:
	var enemy := scene.instantiate()
	enemy.name = "%s%d" % [prefix, index]
	enemy.position = position
	add_child(enemy)


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


func _on_health_changed(current: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = current

	if _last_health >= 0 and current < _last_health:
		AudioManager.play_sfx("hurt")
		var camera := player.get_node_or_null("Camera2D") as PlayerCamera
		if camera != null:
			camera.shake(2.0)
	_last_health = current


func _on_score_changed(score: int) -> void:
	score_label.text = "Score: %d" % score


func _on_weapon_changed(stats: WeaponStats) -> void:
	weapon_label.text = "Weapon: %s" % stats.id.capitalize()


func _on_hit_confirmed(position: Vector2, _target: Node, damage: int) -> void:
	AudioManager.play_sfx("hit")
	hit_stop.trigger(0.04)
	if damage > 0:
		DamageEffect.spawn(self, position, damage)
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
