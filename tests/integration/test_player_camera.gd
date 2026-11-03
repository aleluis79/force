extends GutTest


func test_look_ahead_target_follows_the_aim() -> void:
	var camera := PlayerCamera.new()
	autofree(camera)

	camera.update_look_ahead(Vector2.RIGHT)
	assert_eq(camera.target_offset, Vector2(32, 0))

	camera.update_look_ahead(Vector2.UP)
	assert_eq(camera.target_offset, Vector2(0, -32))

	camera.update_look_ahead(Vector2.ZERO)
	assert_eq(camera.target_offset, Vector2.ZERO)


func test_camera_smooths_toward_the_target() -> void:
	var camera := PlayerCamera.new()
	camera.enabled = false
	add_child_autoqfree(camera)

	camera.update_look_ahead(Vector2.RIGHT)
	await _wait_process_frames(2)

	assert_gt(camera.position.x, 0.0, "camera must start moving toward the target")
	assert_lt(camera.position.x, 32.0, "camera must not snap instantly to the target")

	await _wait_process_frames(120)
	assert_almost_eq(camera.position.x, 32.0, 0.5)


func test_player_scene_has_a_camera() -> void:
	var packed := load("res://scenes/player.tscn") as PackedScene
	assert_not_null(packed, "player scene must load")
	if packed == null:
		return

	var player := packed.instantiate()

	assert_not_null(player.get_node_or_null("Camera2D"), "player scene must include a Camera2D")
	player.free()


func _wait_process_frames(count: int) -> void:
	for index in count:
		await get_tree().process_frame
