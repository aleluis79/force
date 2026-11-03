extends GutTest


func test_terrain_builds_grid_and_tiles() -> void:
	var terrain := _make_terrain()

	assert_not_null(terrain.grid, "terrain must build a grid")
	assert_eq(terrain.grid.width, 60)
	assert_eq(terrain.grid.height, 34)
	assert_gt(terrain.get_solid_cell_count(), 0, "terrain must start with solid cells")
	assert_eq(
		terrain.get_used_cells().size(),
		terrain.get_solid_cell_count(),
		"every solid cell must have a tile"
	)
	assert_ne(
		terrain.get_cell_source_id(Vector2i(0, 33)),
		-1,
		"the bottom row must be rendered"
	)


func test_explosion_destroys_tiles_and_emits_signal() -> void:
	var terrain := _make_terrain()
	var before := terrain.get_solid_cell_count()
	watch_signals(terrain)

	var destroyed := terrain.explode(Vector2(240, 240), 24.0)

	assert_gt(destroyed.size(), 0, "explosion must destroy solid cells")
	assert_eq(terrain.get_solid_cell_count(), before - destroyed.size())
	assert_signal_emitted(terrain, "terrain_destroyed")

	for cell in destroyed:
		assert_false(terrain.grid.is_solid(cell), "destroyed cell must be empty in the grid")
		assert_eq(terrain.get_cell_source_id(cell), -1, "destroyed cell must not have a tile")


func test_explosion_without_solid_cells_does_not_emit_signal() -> void:
	var terrain := _make_terrain()
	watch_signals(terrain)

	var destroyed := terrain.explode(Vector2(-100, -100), 8.0)

	assert_eq(destroyed.size(), 0)
	assert_signal_emit_count(terrain, "terrain_destroyed", 0)


func _make_terrain() -> DestructibleTerrain:
	var terrain := DestructibleTerrain.new()
	add_child_autofree(terrain)
	return terrain


func test_player_lands_on_the_terrain() -> void:
	var terrain := _make_terrain()
	var player := _make_player(Vector2(80, 200))

	await _wait_physics_frames(60)

	assert_true(player.is_on_floor(), "player must land on the destructible terrain")


func test_player_falls_when_the_ground_is_destroyed() -> void:
	var terrain := _make_terrain()
	var player := _make_player(Vector2(80, 200))
	await _wait_physics_frames(60)
	assert_true(player.is_on_floor(), "player must be grounded before the explosion")
	var start_y := player.global_position.y

	var destroyed := terrain.explode(Vector2(player.global_position.x, player.global_position.y + 20.0), 24.0)
	assert_gt(destroyed.size(), 0, "explosion must remove ground under the player")
	await _wait_physics_frames(30)

	assert_gt(player.global_position.y, start_y + 16.0, "player must fall into the hole")
	assert_false(
		terrain.grid.is_solid(Vector2i(int(player.global_position.x / 8.0), 28)),
		"the original supporting cell must be destroyed"
	)


func _make_player(position: Vector2) -> Player:
	var packed := load("res://scenes/player.tscn") as PackedScene
	var player := packed.instantiate() as Player
	player.position = position
	add_child_autoqfree(player)
	return player


func _wait_physics_frames(count: int) -> void:
	for index in count:
		await get_tree().physics_frame
