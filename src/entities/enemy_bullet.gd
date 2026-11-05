class_name EnemyBullet
extends Area2D

## Straight enemy projectile that damages the player and can be shot down.

signal finished(bullet)

const SPEED := 160.0
const LIFETIME := 3.0
const DAMAGE := 20
const TARGET_COLLISION_MASK := 1

var direction := Vector2.LEFT
var terrain: DestructibleTerrain
var lifetime := LIFETIME

var _finished := false


func _ready() -> void:
	add_to_group("enemy_projectiles")


func setup(new_direction: Vector2, new_terrain: DestructibleTerrain) -> void:
	direction = new_direction.normalized() if new_direction.length() > 0.001 else Vector2.LEFT
	terrain = new_terrain
	rotation = direction.angle()
	_finished = false
	show()
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	if _finished:
		return

	var next_position := global_position + direction * SPEED * delta

	if terrain != null and terrain.is_solid_at_world(next_position):
		_finish()
		return

	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		next_position,
		TARGET_COLLISION_MASK
	)
	var hit := get_world_2d().direct_space_state.intersect_ray(query)

	if not hit.is_empty():
		var target: Node = hit.collider
		if target.has_method("take_damage"):
			target.take_damage(DAMAGE)
		_finish()
		return

	global_position = next_position
	lifetime -= delta
	if lifetime <= 0.0:
		_finish()


func take_damage(amount: int) -> int:
	if amount <= 0 or _finished:
		return 0
	_finish()
	return amount


func _finish() -> void:
	if _finished:
		return
	_finished = true
	set_physics_process(false)
	hide()
	finished.emit(self)
	queue_free()
