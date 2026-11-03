extends GutTest


func after_each() -> void:
	Engine.time_scale = 1.0


func test_hit_stop_freezes_and_restores_time_scale() -> void:
	var hit_stop: Node = load("res://src/presentation/hit_stop.gd").new()
	add_child_autoqfree(hit_stop)

	hit_stop.trigger(0.01)

	assert_lt(Engine.time_scale, 1.0, "hit stop must slow the time scale")

	await get_tree().create_timer(0.05, true, false, true).timeout

	assert_almost_eq(Engine.time_scale, 1.0, 0.001, "hit stop must restore the time scale")
