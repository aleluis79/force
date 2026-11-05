class_name DamageEffect
extends Node2D

## Short-lived impact feedback: pixel sparks and a floating damage number.

const FONT := preload("res://assets/fonts/PressStart2P-Regular.ttf")
const LIFETIME := 0.45
const SPARK_COLOR := Color(1.0, 0.86, 0.35)
const STRONG_COLOR := Color(1.0, 0.42, 0.32)
const STRONG_DAMAGE := 30

static var _spark_texture: ImageTexture


func _init() -> void:
	z_index = 50


static func spawn(parent: Node, world_position: Vector2, damage: int) -> DamageEffect:
	var effect := DamageEffect.new()
	effect.process_mode = Node.PROCESS_MODE_PAUSABLE
	parent.add_child(effect)
	effect.global_position = world_position
	effect._build(damage)
	return effect


func _build(damage: int) -> void:
	_add_sparks()
	_add_number(damage)

	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = LIFETIME + 0.15
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()


func _add_sparks() -> void:
	var particles := CPUParticles2D.new()
	particles.texture = _get_spark_texture()
	particles.amount = 10
	particles.lifetime = 0.28
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.direction = Vector2.UP
	particles.spread = 180.0
	particles.gravity = Vector2(0, 240)
	particles.initial_velocity_min = 30.0
	particles.initial_velocity_max = 95.0
	particles.scale_amount_min = 1.0
	particles.scale_amount_max = 2.0
	particles.color = SPARK_COLOR
	particles.emitting = true
	add_child(particles)


func _add_number(damage: int) -> void:
	var label := Label.new()
	label.text = "-%d" % damage
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(48, 10)
	label.position = Vector2(-24, -22)
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", _color_for(damage))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(label)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 14.0, LIFETIME)
	tween.tween_property(label, "modulate:a", 0.0, LIFETIME).set_ease(Tween.EASE_IN)


func _color_for(damage: int) -> Color:
	return STRONG_COLOR if damage >= STRONG_DAMAGE else SPARK_COLOR


static func _get_spark_texture() -> ImageTexture:
	if _spark_texture == null:
		var image := Image.create(2, 2, false, Image.FORMAT_RGBA8)
		image.fill(Color.WHITE)
		_spark_texture = ImageTexture.create_from_image(image)
	return _spark_texture
