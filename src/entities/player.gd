class_name Player
extends CharacterBody2D

## CharacterBody2D adapter for the pure PlayerMotion model.

signal weapon_changed(stats: WeaponStats)

var input_source: InputSource
var motion := PlayerMotion.new()
var aim_direction := Vector2.RIGHT
var weapon_state := WeaponState.new(WeaponStats.rifle())
var terrain: DestructibleTerrain

@onready var _camera: PlayerCamera = get_node_or_null("Camera2D") as PlayerCamera
@onready var bullet_pool: BulletPool = get_node_or_null("BulletPool") as BulletPool


func _ready() -> void:
	if input_source == null:
		input_source = LocalInputSource.new()
	if terrain == null:
		terrain = get_tree().get_first_node_in_group("terrain") as DestructibleTerrain


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

	weapon_state.tick(delta)
	if weapon_state.try_fire(input_source.is_shoot_pressed(), input_source.was_shoot_just_pressed()):
		_fire()


func set_weapon(stats: WeaponStats) -> void:
	weapon_state.set_stats(stats)
	weapon_changed.emit(stats)


func _fire() -> void:
	if bullet_pool == null:
		return

	var stats := weapon_state.stats
	var muzzle_position := global_position + aim_direction * 12.0
	for direction in weapon_state.get_projectile_directions(aim_direction):
		bullet_pool.spawn(muzzle_position, direction, stats, terrain)

	velocity -= aim_direction * stats.recoil
	motion.velocity = velocity
