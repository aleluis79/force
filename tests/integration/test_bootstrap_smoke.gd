extends GutTest

const BOOTSTRAP_SCENE := "res://scenes/bootstrap.tscn"
const INTERNAL_SIZE := Vector2(480, 270)


func test_bootstrap_scene_loads_and_survives_60_physics_frames() -> void:
	var packed := load(BOOTSTRAP_SCENE) as PackedScene
	assert_not_null(packed, "bootstrap scene must load")
	if packed == null:
		return

	var root := packed.instantiate()
	add_child_autofree(root)
	await get_tree().process_frame

	assert_eq(root.name, "Bootstrap", "bootstrap root must be named Bootstrap")

	var background := root.get_node_or_null("Background") as ColorRect
	assert_not_null(background, "bootstrap scene must contain a Background ColorRect")
	if background != null:
		assert_eq(
			background.size,
			INTERNAL_SIZE,
			"background must cover the 480x270 internal resolution"
		)

	for frame in 60:
		await get_tree().physics_frame

	assert_true(is_instance_valid(root), "bootstrap root must survive 60 physics frames")
	assert_eq(root.name, "Bootstrap", "bootstrap root must keep its name")
