class_name Bullet
extends Node2D

## Projectile with deterministic terrain checks and a raycast for targets.

signal finished(bullet)
signal hit_target(target: Node, position: Vector2)

const TARGET_COLLISION_MASK := 2
const TEXTURE := preload("res://assets/sprites/bullet.png")

var direction := Vector2.RIGHT
var speed := 600.0
var damage := 10
var lifetime := 1.0
var terrain_radius := 12.0
var terrain: DestructibleTerrain

var _finished := false


func _ready() -> void:
	var sprite := Sprite2D.new()
	sprite.texture = TEXTURE
	add_child(sprite)


func setup(
	new_direction: Vector2,
	stats: WeaponStats,
	new_terrain: DestructibleTerrain
) -> void:
	direction = new_direction.normalized() if new_direction.length() > 0.001 else Vector2.RIGHT
	rotation = direction.angle()
	speed = stats.bullet_speed
	damage = stats.damage
	lifetime = stats.bullet_lifetime
	terrain_radius = stats.terrain_radius
	terrain = new_terrain
	_finished = false
	show()
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	if _finished:
		return

	var next_position := global_position + direction * speed * delta

	if terrain != null and terrain.is_solid_at_world(next_position):
		terrain.explode(next_position, terrain_radius)
		_finish()
		return

	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		next_position,
		TARGET_COLLISION_MASK
	)
	query.collide_with_areas = true
	var hit := get_world_2d().direct_space_state.intersect_ray(query)

	if not hit.is_empty():
		var target: Node = hit.collider
		if target.has_method("take_damage"):
			target.take_damage(damage)
			hit_target.emit(target, hit.position)
		_finish()
		return

	global_position = next_position
	lifetime -= delta
	if lifetime <= 0.0:
		_finish()


func _finish() -> void:
	if _finished:
		return
	_finished = true
	set_physics_process(false)
	hide()
	finished.emit(self)
