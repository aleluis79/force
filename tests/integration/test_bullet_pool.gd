extends GutTest


func test_spawn_creates_an_active_bullet() -> void:
	var pool := _make_pool()

	var bullet := pool.spawn(Vector2.ZERO, Vector2.RIGHT, WeaponStats.rifle(), null)

	assert_not_null(bullet)
	assert_eq(pool.active_count(), 1)
	assert_eq(pool.inactive_count(), 0)
	assert_true(bullet.is_physics_processing())


func test_finished_bullet_is_reused() -> void:
	var pool := _make_pool()
	var first := pool.spawn(Vector2.ZERO, Vector2.RIGHT, WeaponStats.rifle(), null)

	first.finished.emit(first)

	assert_eq(pool.active_count(), 0)
	assert_eq(pool.inactive_count(), 1)

	var second := pool.spawn(Vector2.ZERO, Vector2.RIGHT, WeaponStats.rifle(), null)

	assert_eq(second, first, "pool must reuse the inactive instance")
	assert_eq(pool.total_count(), 1)


func test_pool_respects_max_active_bullets() -> void:
	var pool := _make_pool(1)
	pool.spawn(Vector2.ZERO, Vector2.RIGHT, WeaponStats.rifle(), null)

	var second := pool.spawn(Vector2.ZERO, Vector2.RIGHT, WeaponStats.rifle(), null)

	assert_null(second)
	assert_eq(pool.active_count(), 1)


func test_bullet_expires_and_returns_to_pool() -> void:
	var pool := _make_pool()
	var stats := WeaponStats.rifle()
	stats.bullet_lifetime = 0.01
	pool.spawn(Vector2.ZERO, Vector2.RIGHT, stats, null)

	await _wait_physics_frames(5)

	assert_eq(pool.active_count(), 0)
	assert_eq(pool.inactive_count(), 1)


func _make_pool(max_active: int = 64) -> BulletPool:
	var pool := BulletPool.new()
	pool.max_active = max_active
	add_child_autoqfree(pool)
	return pool


func _wait_physics_frames(count: int) -> void:
	for index in count:
		await get_tree().physics_frame
