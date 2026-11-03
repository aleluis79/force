class_name Health
extends RefCounted

## Pure health pool shared by the player, enemies and training targets.

signal damaged(amount: int, current: int)
signal died

var max_health: int
var current: int


func _init(max_value: int = 100) -> void:
	max_health = maxi(max_value, 1)
	current = max_health


func is_dead() -> bool:
	return current <= 0


func damage(amount: int) -> int:
	if amount <= 0 or is_dead():
		return 0

	var applied := mini(amount, current)
	current -= applied
	damaged.emit(applied, current)

	if current == 0:
		died.emit()

	return applied
