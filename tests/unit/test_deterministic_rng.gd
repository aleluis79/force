extends GutTest


func test_same_seed_produces_same_sequence() -> void:
	var first := DeterministicRng.new(12345)
	var second := DeterministicRng.new(12345)

	for index in 10:
		assert_eq(
			first.next_int(0, 1000),
			second.next_int(0, 1000),
			"integer %d must match for the same seed" % index
		)
		assert_eq(
			first.next_float(),
			second.next_float(),
			"float %d must match for the same seed" % index
		)


func test_different_seeds_produce_different_sequences() -> void:
	var first := DeterministicRng.new(1)
	var second := DeterministicRng.new(2)
	var first_values: Array[int] = []
	var second_values: Array[int] = []

	for index in 10:
		first_values.append(first.next_int(0, 1000000))
		second_values.append(second.next_int(0, 1000000))

	assert_ne(first_values, second_values, "different seeds must not produce the same sequence")


func test_reset_reproduces_the_sequence() -> void:
	var rng := DeterministicRng.new(777)
	var expected: Array[int] = []

	for index in 5:
		expected.append(rng.next_int(0, 1000))

	rng.reset(777)

	for index in 5:
		assert_eq(
			rng.next_int(0, 1000),
			expected[index],
			"reset must reproduce value %d" % index
		)


func test_next_int_stays_within_bounds() -> void:
	var rng := DeterministicRng.new(42)

	for index in 100:
		var value := rng.next_int(-5, 5)
		assert_true(value >= -5 and value <= 5, "value %d must be within [-5, 5]" % value)


func test_next_bool_handles_extreme_probabilities() -> void:
	var rng := DeterministicRng.new(99)

	for index in 20:
		assert_false(rng.next_bool(0.0), "probability 0 must always return false")
		assert_true(rng.next_bool(1.0), "probability 1 must always return true")
