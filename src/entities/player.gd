class_name Player
extends CharacterBody2D

## CharacterBody2D adapter for the pure PlayerMotion model.

signal weapon_changed(stats: WeaponStats)
signal health_changed(current: int, max_health: int)
signal died

const WEAPON_SHOULDER := Vector2(3.0, -15.0)
const WEAPON_MUZZLE := Vector2(10.0, 1.0)
const BODY_TEXTURE := preload("res://assets/sprites/player_body.png")
const BODY_CROUCH_TEXTURE := preload("res://assets/sprites/player_body_crouch.png")
const HIT_INVULNERABILITY := 0.6
const RESPAWN_INVULNERABILITY := 1.0
const CROUCH_HEIGHT := 20.0
const CROUCH_COLLIDER_OFFSET := 4.0
const CROUCH_SHOULDER_OFFSET := 17.0
const CROUCH_SPEED_MULTIPLIER := 0.55

var input_source: InputSource
var motion := PlayerMotion.new()
var aim_direction := Vector2.RIGHT
var weapon_state := WeaponState.new(WeaponStats.rifle())
var health := Health.new(100)
var terrain: DestructibleTerrain
var alive := true
var invulnerable := false
var crouching := false

@onready var _camera: PlayerCamera = get_node_or_null("Camera2D") as PlayerCamera
@onready var bullet_pool: BulletPool = get_node_or_null("BulletPool") as BulletPool
@onready var _sprite: Sprite2D = get_node_or_null("Sprite") as Sprite2D
@onready var _collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D
@onready var _weapon_pivot: Node2D = get_node_or_null("WeaponPivot") as Node2D
@onready var _weapon_sprite: Sprite2D = get_node_or_null("WeaponPivot/Weapon") as Sprite2D
@onready var _muzzle: Marker2D = get_node_or_null("WeaponPivot/Muzzle") as Marker2D

var _invulnerability_timer: Timer
var _stand_shape: RectangleShape2D
var _crouch_shape: RectangleShape2D


func _ready() -> void:
	add_to_group("player")
	if input_source == null:
		input_source = LocalInputSource.new()
	if terrain == null:
		terrain = get_tree().get_first_node_in_group("terrain") as DestructibleTerrain

	health.damaged.connect(_on_health_damaged)
	health.died.connect(_on_health_died)
	_setup_crouch_shapes()

	_invulnerability_timer = Timer.new()
	_invulnerability_timer.one_shot = true
	_invulnerability_timer.timeout.connect(_clear_invulnerability)
	add_child(_invulnerability_timer)


func _physics_process(delta: float) -> void:
	aim_direction = input_source.get_aim_direction(global_position, get_global_mouse_position())
	_set_crouching(input_source.is_crouch_pressed() and is_on_floor())

	velocity = motion.tick(
		delta,
		input_source.get_move_axis(),
		input_source.was_jump_just_pressed(),
		input_source.was_jump_just_released(),
		is_on_floor()
	)

	if crouching:
		var max_crouch_speed := PlayerMotion.MAX_SPEED * CROUCH_SPEED_MULTIPLIER
		velocity.x = clampf(velocity.x, -max_crouch_speed, max_crouch_speed)

	move_and_slide()

	motion.velocity = velocity
	motion.grounded = is_on_floor()

	if _camera != null:
		_camera.update_look_ahead(aim_direction)

	_update_sprite()
	_update_weapon()

	if motion.jumped_this_tick:
		AudioManager.play_sfx("jump")

	weapon_state.tick(delta)
	if weapon_state.try_fire(input_source.is_shoot_pressed(), input_source.was_shoot_just_pressed()):
		_fire()


func take_damage(amount: int = 1) -> int:
	if not alive or invulnerable or amount <= 0:
		return 0

	var applied := health.damage(amount)
	if applied > 0:
		_start_invulnerability(HIT_INVULNERABILITY)
	return applied


func _start_invulnerability(duration: float) -> void:
	invulnerable = true
	if _invulnerability_timer != null:
		_invulnerability_timer.start(duration)


func _setup_crouch_shapes() -> void:
	if _collision_shape == null or not (_collision_shape.shape is RectangleShape2D):
		return

	_stand_shape = (_collision_shape.shape as RectangleShape2D).duplicate() as RectangleShape2D
	_crouch_shape = _stand_shape.duplicate() as RectangleShape2D
	_crouch_shape.size = Vector2(_stand_shape.size.x, CROUCH_HEIGHT)
	_collision_shape.shape = _stand_shape


func _set_crouching(value: bool) -> void:
	if value == crouching:
		return

	crouching = value
	if _collision_shape == null or _stand_shape == null or _crouch_shape == null:
		return

	_collision_shape.shape = _crouch_shape if crouching else _stand_shape
	_collision_shape.position = Vector2(0, CROUCH_COLLIDER_OFFSET) if crouching else Vector2.ZERO


func _on_health_damaged(_amount: int, current: int) -> void:
	health_changed.emit(current, health.max_health)


func _on_health_died() -> void:
	if not alive:
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
	health.current = health.max_health
	health_changed.emit(health.current, health.max_health)
	alive = true
	visible = true
	_set_crouching(false)
	_start_invulnerability(RESPAWN_INVULNERABILITY)
	set_physics_process(true)


func _clear_invulnerability() -> void:
	invulnerable = false


func set_weapon(stats: WeaponStats) -> void:
	weapon_state.set_stats(stats)
	weapon_changed.emit(stats)


func _fire() -> void:
	if bullet_pool == null:
		return

	_update_weapon()
	var stats := weapon_state.stats
	var muzzle_position := _muzzle.global_position if _muzzle != null else _fallback_muzzle_position()
	for direction in weapon_state.get_projectile_directions(aim_direction):
		bullet_pool.spawn(muzzle_position, direction, stats, terrain)

	AudioManager.play_sfx("shotgun" if stats.id == "shotgun" else "shoot")
	velocity -= aim_direction * stats.recoil
	motion.velocity = velocity


func _update_weapon() -> void:
	if _weapon_pivot == null:
		return

	var aim_facing := 1.0 if aim_direction.x >= 0.0 else -1.0
	if absf(aim_direction.x) < 0.01:
		aim_facing = -1.0 if _sprite != null and _sprite.flip_h else 1.0

	_weapon_pivot.position = Vector2(
		WEAPON_SHOULDER.x * aim_facing,
		WEAPON_SHOULDER.y + (CROUCH_SHOULDER_OFFSET if crouching else 0.0)
	)
	_weapon_pivot.scale = Vector2(1.0, -1.0 if aim_facing < 0.0 else 1.0)
	_weapon_pivot.rotation = aim_direction.angle()

	if _weapon_sprite != null and _sprite != null:
		_weapon_sprite.frame = _sprite.frame


func _fallback_muzzle_position() -> Vector2:
	var facing := 1.0 if aim_direction.x >= 0.0 else -1.0
	return global_position + Vector2(WEAPON_MUZZLE.x * facing, WEAPON_SHOULDER.y + WEAPON_MUZZLE.y)


func _update_sprite() -> void:
	if _sprite == null:
		return

	_sprite.texture = BODY_CROUCH_TEXTURE if crouching else BODY_TEXTURE
	_sprite.scale = Vector2.ONE

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
