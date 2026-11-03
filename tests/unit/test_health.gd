extends GutTest


func test_health_starts_full() -> void:
	var health := Health.new(100)

	assert_eq(health.max_health, 100)
	assert_eq(health.current, 100)
	assert_false(health.is_dead())


func test_damage_reduces_current_health() -> void:
	var health := Health.new(100)

	var applied := health.damage(30)

	assert_eq(applied, 30)
	assert_eq(health.current, 70)
	assert_false(health.is_dead())


func test_lethal_damage_clamps_to_zero() -> void:
	var health := Health.new(100)

	var applied := health.damage(150)

	assert_eq(applied, 100)
	assert_eq(health.current, 0)
	assert_true(health.is_dead())


func test_invalid_damage_is_ignored() -> void:
	var health := Health.new(100)

	assert_eq(health.damage(0), 0)
	assert_eq(health.damage(-10), 0)
	assert_eq(health.current, 100)


func test_damage_and_death_signals_are_emitted() -> void:
	var health := Health.new(100)
	watch_signals(health)

	health.damage(20)
	assert_signal_emitted_with_parameters(health, "damaged", [20, 80])

	health.damage(80)
	assert_signal_emitted(health, "died")


func test_damage_after_death_does_nothing() -> void:
	var health := Health.new(10)
	health.damage(10)

	assert_eq(health.damage(5), 0)
	assert_eq(health.current, 0)
