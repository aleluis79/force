class_name Player
extends CharacterBody2D

## CharacterBody2D adapter for the pure PlayerMotion model.

signal weapon_changed(stats: WeaponStats)
signal died

const MUZZLE_HEIGHT := -6.0
const MUZZLE_FORWARD := 6.0
const MUZZLE_EXTENSION := 10.0

var input_source: InputSource
var motion := PlayerMotion.new()
var aim_direction := Vector2.RIGHT
var weapon_state := WeaponState.new(WeaponStats.rifle())
var terrain: DestructibleTerrain
var alive := true
var invulnerable := false

@onready var _camera: PlayerCamera = get_node_or_null("Camera2D") as PlayerCamera
@onready var bullet_pool: BulletPool = get_node_or_null("BulletPool") as BulletPool
@onready var _sprite: Sprite2D = get_node_or_null("Sprite") as Sprite2D

var _invulnerability_timer: Timer


func _ready() -> void:
	add_to_group("player")
	if input_source == null:
		input_source = LocalInputSource.new()
	if terrain == null:
		terrain = get_tree().get_first_node_in_group("terrain") as DestructibleTerrain

	_invulnerability_timer = Timer.new()
	_invulnerability_timer.one_shot = true
	_invulnerability_timer.timeout.connect(_clear_invulnerability)
	add_child(_invulnerability_timer)


func _physics_process(delta: float) -> void:
	aim_direction = input_source.get_aim_direction(global_position, get_global_mouse_position())

	velocity = motion.tick(
		delta,
		input_source.get_move_axis(),
		input_source.was_jump_just_pressed(),
		input_source.was_jump_just_released(),
		is_on_floor()
	)

	move_and_slide()

	motion.velocity = velocity
	motion.grounded = is_on_floor()

	if _camera != null:
		_camera.update_look_ahead(aim_direction)

	_update_sprite()

	if motion.jumped_this_tick:
		AudioManager.play_sfx("jump")

	weapon_state.tick(delta)
	if weapon_state.try_fire(input_source.is_shoot_pressed(), input_source.was_shoot_just_pressed()):
		_fire()


func take_damage(_amount: int = 1) -> void:
	if not alive or invulnerable:
		return

	alive = false
	visible = false
	velocity = Vector2.ZERO
	set_physics_process(false)
	died.emit()


func respawn(position: Vector2) -> void:
	global_position = position
	velocity = Vector2.ZERO
	motion.reset()
	alive = true
	visible = true
	invulnerable = true
	set_physics_process(true)
	if _invulnerability_timer != null:
		_invulnerability_timer.start(1.0)


func _clear_invulnerability() -> void:
	invulnerable = false


func set_weapon(stats: WeaponStats) -> void:
	weapon_state.set_stats(stats)
	weapon_changed.emit(stats)


func _fire() -> void:
	if bullet_pool == null:
		return

	var stats := weapon_state.stats
	var facing := 1.0 if aim_direction.x >= 0.0 else -1.0
	var muzzle_origin := global_position + Vector2(MUZZLE_FORWARD * facing, MUZZLE_HEIGHT)
	var muzzle_position := muzzle_origin + aim_direction * MUZZLE_EXTENSION
	for direction in weapon_state.get_projectile_directions(aim_direction):
		bullet_pool.spawn(muzzle_position, direction, stats, terrain)

	AudioManager.play_sfx("shotgun" if stats.id == "shotgun" else "shoot")
	velocity -= aim_direction * stats.recoil
	motion.velocity = velocity


func _update_sprite() -> void:
	if _sprite == null:
		return

	if not is_on_floor():
		_sprite.frame = 5
	elif absf(velocity.x) > 1.0:
		_sprite.frame = 1 + int(Time.get_ticks_msec() / 90) % 4
	else:
		_sprite.frame = 0

	var move_axis := input_source.get_move_axis()
	if absf(move_axis) > 0.1:
		_sprite.flip_h = move_axis < 0.0
	elif absf(velocity.x) > 1.0:
		_sprite.flip_h = velocity.x < 0.0
	else:
		_sprite.flip_h = aim_direction.x < -0.01
