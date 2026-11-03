extends Node

## Brief global freeze used for hit feedback. Restores the real time scale.

var _generation := 0


func trigger(duration: float) -> void:
	_generation += 1
	var generation := _generation
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration, true, false, true).timeout
	if generation == _generation:
		Engine.time_scale = 1.0
