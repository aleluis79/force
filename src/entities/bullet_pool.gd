class_name BulletPool
extends Node2D

## Reuses Bullet instances and re-emits target hits for presentation feedback.

signal hit_confirmed(position: Vector2, target: Node, damage: int)

@export var max_active := 64

var _active: Array[Bullet] = []
var _inactive: Array[Bullet] = []


func spawn(
	position: Vector2,
	direction: Vector2,
	stats: WeaponStats,
	terrain: DestructibleTerrain
) -> Bullet:
	if _active.size() >= max_active:
		return null

	var bullet: Bullet
	if _inactive.is_empty():
		bullet = Bullet.new()
		bullet.finished.connect(_on_bullet_finished)
		bullet.hit_target.connect(_on_bullet_hit_target)
		add_child(bullet)
	else:
		bullet = _inactive.pop_back()

	bullet.global_position = position
	bullet.setup(direction, stats, terrain)
	_active.append(bullet)
	return bullet


func active_count() -> int:
	return _active.size()


func inactive_count() -> int:
	return _inactive.size()


func total_count() -> int:
	return _active.size() + _inactive.size()


func _on_bullet_finished(bullet: Bullet) -> void:
	_active.erase(bullet)
	if not _inactive.has(bullet):
		_inactive.append(bullet)


func _on_bullet_hit_target(target: Node, position: Vector2, damage: int) -> void:
	hit_confirmed.emit(position, target, damage)
