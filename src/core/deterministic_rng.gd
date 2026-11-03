class_name DeterministicRng
extends RefCounted

## Seeded random number generator for gameplay logic.
##
## Core code must not use the global RNG helpers; injecting this object keeps
## simulations reproducible and testable.

var _rng := RandomNumberGenerator.new()


func _init(seed_value: int = 0) -> void:
	reset(seed_value)


func reset(seed_value: int) -> void:
	_rng.seed = seed_value


func next_int(min_value: int, max_value: int) -> int:
	return _rng.randi_range(min_value, max_value)


func next_float() -> float:
	return _rng.randf_range(0.0, 1.0)


func next_bool(probability: float = 0.5) -> bool:
	return next_float() < probability
