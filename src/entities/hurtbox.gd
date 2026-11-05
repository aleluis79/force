class_name Hurtbox
extends Area2D

## Forwards bullet damage to its owner while covering the full sprite.

var _target: Node


func _ready() -> void:
	_target = get_parent()


func take_damage(amount: int) -> int:
	if _target == null or not _target.has_method("take_damage"):
		return 0
	return _target.take_damage(amount)
