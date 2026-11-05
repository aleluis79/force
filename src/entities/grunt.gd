class_name Grunt
extends CharacterBody2D

## Ground enemy that walks toward the player and damages on contact.

signal died(points: int)

const GRAVITY := 900.0
const SPEED := 40.0
const CONTACT_RANGE := 18.0
const CONTACT_DAMAGE := 20
const SHOOT_RANGE := 300.0
const SHOOT_INTERVAL := 0.9
const SHOOT_MUZZLE := Vector2(0, -15)
const AIM_HEIGHT := -12.0
const ENEMY_BULLET_SCENE := preload("res://scenes/enemy_bullet.tscn")

@export var score_value := 100

var health := Health.new(30)
var shots_fired := 0
var _player: Player
var _shoot_cooldown := 0.0

@onready var _sprite: Sprite2D = get_node_or_null("Sprite") as Sprite2D


func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 2
	collision_mask = 1
	health.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	_shoot_cooldown = maxf(_shoot_cooldown - delta, 0.0)

	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as Player

	var facing_direction := 0.0
	if _player != null and _player.alive:
		facing_direction = signf(_player.global_position.x - global_position.x)
		velocity.x = facing_direction * SPEED
		if global_position.distance_to(_player.global_position) < CONTACT_RANGE:
			_player.take_damage(CONTACT_DAMAGE)
		_try_shoot()
	else:
		velocity.x = 0.0

	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y += GRAVITY * delta

	move_and_slide()

	if _sprite != null:
		_sprite.frame = int(Time.get_ticks_msec() / 150) % 2
		# The grunt art faces left by default.
		_sprite.flip_h = facing_direction > 0.1


func _try_shoot() -> void:
	if _shoot_cooldown > 0.0 or _player == null or not _player.alive:
		return
	if global_position.distance_to(_player.global_position) > SHOOT_RANGE:
		return

	var muzzle := global_position + SHOOT_MUZZLE
	var target := _player.global_position + Vector2(0, AIM_HEIGHT)
	var direction := (target - muzzle).normalized()
	var bullet := ENEMY_BULLET_SCENE.instantiate() as EnemyBullet
	get_parent().add_child(bullet)
	bullet.global_position = muzzle
	bullet.setup(direction, get_tree().get_first_node_in_group("terrain") as DestructibleTerrain)

	shots_fired += 1
	_shoot_cooldown = SHOOT_INTERVAL


func take_damage(amount: int) -> int:
	var applied := health.damage(amount)
	if applied > 0:
		HitFlash.play(self, _sprite)
	return applied


func _on_died() -> void:
	died.emit(score_value)
	queue_free()
