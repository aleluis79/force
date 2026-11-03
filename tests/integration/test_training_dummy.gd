extends GutTest

const DUMMY_SCENE := "res://scenes/training_dummy.tscn"


func test_dummy_takes_damage() -> void:
	var dummy := _make_dummy()

	dummy.take_damage(30)

	assert_eq(dummy.health.current, 70)
	assert_false(dummy.health.is_dead())


func test_dummy_dies_and_hides() -> void:
	var dummy := _make_dummy()
	watch_signals(dummy)

	dummy.take_damage(100)

	assert_true(dummy.health.is_dead())
	assert_false(dummy.visible, "dead dummy must hide")
	assert_signal_emitted(dummy, "died")


func _make_dummy() -> TrainingDummy:
	var packed := load(DUMMY_SCENE) as PackedScene
	var dummy := packed.instantiate() as TrainingDummy
	add_child_autoqfree(dummy)
	return dummy
