class_name WeaponState
extends RefCounted

## Pure weapon cooldown and projectile spread logic.

var stats: WeaponStats
var _cooldown := 0.0


func _init(weapon_stats: WeaponStats) -> void:
	stats = weapon_stats


func set_stats(new_stats: WeaponStats) -> void:
	stats = new_stats
	_cooldown = 0.0


func tick(delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)


func can_fire() -> bool:
	return _cooldown <= 0.0


func try_fire(held: bool, just_pressed: bool) -> bool:
	if not can_fire():
		return false

	if stats.automatic:
		if not held:
			return false
	elif not just_pressed:
		return false

	_cooldown = 1.0 / maxf(stats.shots_per_second, 0.001)
	return true


func get_projectile_directions(aim: Vector2) -> Array[Vector2]:
	var directions: Array[Vector2] = []
	var base := aim.normalized() if aim.length() > 0.001 else Vector2.RIGHT
	var count := maxi(stats.projectile_count, 1)

	if count == 1:
		directions.append(base)
		return directions

	var half_spread := deg_to_rad(stats.spread_degrees) * 0.5
	for index in count:
		var ratio := float(index) / float(count - 1)
		var angle := lerpf(-half_spread, half_spread, ratio)
		directions.append(base.rotated(angle))

	return directions
