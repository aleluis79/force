extends GutTest


func test_rifle_stats_are_automatic_and_single_projectile() -> void:
	var stats := WeaponStats.rifle()

	assert_eq(stats.id, "rifle")
	assert_true(stats.automatic)
	assert_eq(stats.projectile_count, 1)
	assert_gt(stats.shots_per_second, 0.0)
	assert_gt(stats.damage, 0)


func test_shotgun_stats_are_semi_automatic_and_multiple_projectiles() -> void:
	var stats := WeaponStats.shotgun()

	assert_eq(stats.id, "shotgun")
	assert_false(stats.automatic)
	assert_gt(stats.projectile_count, 1)
	assert_gt(stats.spread_degrees, 0.0)


func test_rifle_fires_while_held_and_respects_cooldown() -> void:
	var weapon := WeaponState.new(WeaponStats.rifle())

	assert_true(weapon.try_fire(true, true), "first shot must fire")
	assert_false(weapon.try_fire(true, false), "cooldown must block the next shot")

	weapon.tick(0.2)
	assert_true(weapon.try_fire(true, false), "held trigger must fire after cooldown")


func test_rifle_does_not_fire_when_released() -> void:
	var weapon := WeaponState.new(WeaponStats.rifle())

	assert_false(weapon.try_fire(false, false))


func test_shotgun_requires_a_new_press() -> void:
	var weapon := WeaponState.new(WeaponStats.shotgun())

	assert_true(weapon.try_fire(true, true))
	weapon.tick(1.0)
	assert_false(weapon.try_fire(true, false), "holding the trigger must not repeat the shotgun")
	assert_true(weapon.try_fire(false, true), "a new press must fire the shotgun")


func test_changing_weapon_resets_cooldown_and_stats() -> void:
	var weapon := WeaponState.new(WeaponStats.rifle())
	weapon.try_fire(true, true)

	weapon.set_stats(WeaponStats.shotgun())

	assert_eq(weapon.stats.id, "shotgun")
	assert_true(weapon.can_fire())


func test_rifle_generates_one_normalized_direction() -> void:
	var weapon := WeaponState.new(WeaponStats.rifle())

	var directions := weapon.get_projectile_directions(Vector2.RIGHT)

	assert_eq(directions.size(), 1)
	assert_almost_eq(directions[0].x, 1.0, 0.001)
	assert_almost_eq(directions[0].length(), 1.0, 0.001)


func test_shotgun_spreads_projectiles_evenly() -> void:
	var weapon := WeaponState.new(WeaponStats.shotgun())

	var directions := weapon.get_projectile_directions(Vector2.RIGHT)

	assert_eq(directions.size(), 5)
	assert_almost_eq(directions[0].angle(), deg_to_rad(-9.0), 0.001)
	assert_almost_eq(directions[4].angle(), deg_to_rad(9.0), 0.001)
	for direction in directions:
		assert_almost_eq(direction.length(), 1.0, 0.001)
