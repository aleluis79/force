class_name TrainingDummy
extends Area2D

## Damageable practice target for combat integration tests.

signal died

var health := Health.new(100)

@onready var _sprite: Sprite2D = get_node_or_null("Sprite") as Sprite2D


func _ready() -> void:
	collision_layer = 2
	collision_mask = 0
	health.died.connect(_on_died)


func take_damage(amount: int) -> int:
	var applied := health.damage(amount)
	if applied > 0:
		HitFlash.play(self, _sprite)
	return applied


func _on_died() -> void:
	visible = false
	set_deferred("monitorable", false)
	died.emit()
