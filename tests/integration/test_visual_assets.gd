extends GutTest


func test_actor_scenes_have_sprite_textures() -> void:
	var scenes := {
		"res://scenes/player.tscn": 6,
		"res://scenes/grunt.tscn": 2,
		"res://scenes/kamikaze.tscn": 2,
		"res://scenes/pow.tscn": 2,
		"res://scenes/training_dummy.tscn": 1,
	}

	for path in scenes:
		var packed := load(path) as PackedScene
		assert_not_null(packed, "scene must load: %s" % path)
		var node := packed.instantiate()
		var sprite := node.get_node_or_null("Sprite") as Sprite2D
		assert_not_null(sprite, "scene must have a Sprite: %s" % path)
		if sprite != null:
			assert_not_null(sprite.texture, "sprite must have a texture: %s" % path)
			assert_eq(sprite.hframes, scenes[path], "unexpected frame count: %s" % path)
		node.free()


func test_background_has_three_parallax_layers() -> void:
	var packed := load("res://scenes/background.tscn") as PackedScene
	assert_not_null(packed)
	var background := packed.instantiate()

	assert_eq(background.get_child_count(), 3)
	for layer in background.get_children():
		assert_true(layer is ParallaxLayer, "background children must be ParallaxLayer")

	background.free()


func test_pixel_theme_uses_press_start_font() -> void:
	var theme := load("res://assets/theme/game_theme.tres") as Theme
	assert_not_null(theme)
	assert_not_null(theme.default_font, "theme must define a font")
	assert_eq(theme.default_font_size, 8)


func test_bullet_uses_a_sprite() -> void:
	var bullet := Bullet.new()
	add_child_autoqfree(bullet)

	var sprite := bullet.get_child(0) as Sprite2D
	assert_not_null(sprite, "bullet must create a Sprite2D")
	if sprite != null:
		assert_not_null(sprite.texture, "bullet sprite must have a texture")
