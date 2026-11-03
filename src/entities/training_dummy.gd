class_name TrainingDummy
extends Area2D

## Damageable practice target for combat integration tests.

signal died

var health := Health.new(100)


func _ready() -> void:
	collision_layer = 2
	collision_mask = 0
	health.died.connect(_on_died)


func take_damage(amount: int) -> void:
	health.damage(amount)


func _on_died() -> void:
	visible = false
	set_deferred("monitorable", false)
	died.emit()
