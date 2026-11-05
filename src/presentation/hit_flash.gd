class_name HitFlash
extends RefCounted

## Brief red flash and squash used by damageable enemies.

const DURATION := 0.15
const COLOR := Color(1.0, 0.3, 0.3)
const SQUASH := Vector2(1.18, 0.86)
const TWEEN_META := "_hit_flash_tween"


static func play(host: Node, sprite: Sprite2D) -> void:
	if sprite == null:
		return

	var previous = null
	if host.has_meta(TWEEN_META):
		previous = host.get_meta(TWEEN_META)
	if previous is Tween and previous.is_valid():
		previous.kill()

	sprite.modulate = COLOR
	sprite.scale = SQUASH
	var tween := host.create_tween().set_parallel(true)
	tween.tween_property(sprite, "modulate", Color.WHITE, DURATION)
	tween.tween_property(sprite, "scale", Vector2.ONE, DURATION)
	host.set_meta(TWEEN_META, tween)
