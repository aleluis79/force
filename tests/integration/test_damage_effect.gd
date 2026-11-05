extends GutTest


func test_damage_effect_shows_sparks_and_a_number() -> void:
	var parent := Node2D.new()
	add_child_autoqfree(parent)

	var effect := DamageEffect.spawn(parent, Vector2(32, 48), 10)

	assert_almost_eq(effect.global_position.x, 32.0, 0.01)
	assert_almost_eq(effect.global_position.y, 48.0, 0.01)

	var label := _find_child(effect, "Label") as Label
	assert_not_null(label, "damage effect must show a floating number")
	if label != null:
		assert_eq(label.text, "-10")

	var sparks := _find_child(effect, "CPUParticles2D") as CPUParticles2D
	assert_not_null(sparks, "damage effect must emit impact sparks")
	if sparks != null:
		assert_true(sparks.emitting)


func test_grunt_returns_applied_damage_and_flashes() -> void:
	var packed := load("res://scenes/grunt.tscn") as PackedScene
	var grunt := packed.instantiate() as Grunt
	add_child_autoqfree(grunt)
	var sprite := grunt.get_node("Sprite") as Sprite2D

	assert_eq(grunt.take_damage(10), 10)
	assert_eq(grunt.health.current, 20)
	assert_eq(sprite.modulate, Color(1.0, 0.3, 0.3), "hit enemy must flash red")


func test_grunt_flash_returns_to_normal() -> void:
	var packed := load("res://scenes/grunt.tscn") as PackedScene
	var grunt := packed.instantiate() as Grunt
	add_child_autoqfree(grunt)
	var sprite := grunt.get_node("Sprite") as Sprite2D

	grunt.take_damage(10)
	await get_tree().create_timer(0.25).timeout

	assert_eq(sprite.modulate, Color.WHITE)
	assert_eq(sprite.scale, Vector2.ONE)


func test_kamikaze_returns_applied_damage() -> void:
	var packed := load("res://scenes/kamikaze.tscn") as PackedScene
	var kamikaze := packed.instantiate() as Kamikaze
	add_child_autoqfree(kamikaze)

	assert_eq(kamikaze.take_damage(10), 10)
	assert_true(kamikaze.health.is_dead())


func _find_child(node: Node, type_name: String) -> Node:
	for child in node.get_children():
		if child.get_class() == type_name:
			return child
	return null
