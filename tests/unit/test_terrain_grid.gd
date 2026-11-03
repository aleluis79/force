extends GutTest


func test_new_grid_starts_empty() -> void:
	var grid := TerrainGrid.new(4, 3)

	assert_eq(grid.solid_count(), 0)
	assert_false(grid.is_solid(Vector2i(0, 0)))


func test_filled_grid_starts_solid() -> void:
	var grid := TerrainGrid.new(4, 3, true)

	assert_eq(grid.solid_count(), 12)
	assert_true(grid.is_solid(Vector2i(3, 2)))


func test_out_of_bounds_cells_are_empty() -> void:
	var grid := TerrainGrid.new(4, 3, true)

	assert_false(grid.is_solid(Vector2i(-1, 0)))
	assert_false(grid.is_solid(Vector2i(4, 0)))
	assert_false(grid.is_solid(Vector2i(0, -1)))
	assert_false(grid.is_solid(Vector2i(0, 3)))


func test_set_solid_updates_the_count() -> void:
	var grid := TerrainGrid.new(4, 3)

	grid.set_solid(Vector2i(1, 1), true)
	assert_true(grid.is_solid(Vector2i(1, 1)))
	assert_eq(grid.solid_count(), 1)

	grid.set_solid(Vector2i(1, 1), false)
	assert_false(grid.is_solid(Vector2i(1, 1)))
	assert_eq(grid.solid_count(), 0)


func test_set_solid_outside_bounds_is_ignored() -> void:
	var grid := TerrainGrid.new(4, 3)

	grid.set_solid(Vector2i(-1, 0), true)
	grid.set_solid(Vector2i(4, 0), true)

	assert_eq(grid.solid_count(), 0)


func test_fill_rect_marks_every_cell_inside() -> void:
	var grid := TerrainGrid.new(5, 5)

	grid.fill_rect(Rect2i(1, 1, 2, 2))

	assert_eq(grid.solid_count(), 4)
	assert_true(grid.is_solid(Vector2i(1, 1)))
	assert_true(grid.is_solid(Vector2i(2, 2)))
	assert_false(grid.is_solid(Vector2i(0, 0)))


func test_fill_rect_clips_to_grid_bounds() -> void:
	var grid := TerrainGrid.new(4, 4)

	grid.fill_rect(Rect2i(-2, -2, 4, 4))

	assert_eq(grid.solid_count(), 4)
	assert_true(grid.is_solid(Vector2i(0, 0)))
	assert_true(grid.is_solid(Vector2i(1, 1)))
	assert_false(grid.is_solid(Vector2i(2, 2)))


func test_destroy_circle_removes_solid_cells_inside_radius() -> void:
	var grid := TerrainGrid.new(10, 10, true)

	var destroyed := grid.destroy_circle(Vector2(5, 5), 2.0)

	assert_eq(destroyed.size(), 12)
	assert_eq(grid.solid_count(), 100 - 12)
	for cell in destroyed:
		assert_false(grid.is_solid(cell), "destroyed cell must become empty")


func test_destroy_circle_returns_only_solid_cells() -> void:
	var grid := TerrainGrid.new(10, 10, true)
	grid.set_solid(Vector2i(5, 5), false)

	var destroyed := grid.destroy_circle(Vector2(5, 5), 2.0)

	assert_false(destroyed.has(Vector2i(5, 5)), "empty cells must not be returned")
	assert_eq(destroyed.size(), 11)


func test_destroy_circle_is_idempotent() -> void:
	var grid := TerrainGrid.new(10, 10, true)
	var first := grid.destroy_circle(Vector2(5, 5), 2.0)

	var second := grid.destroy_circle(Vector2(5, 5), 2.0)

	assert_gt(first.size(), 0)
	assert_eq(second.size(), 0, "a repeated explosion must destroy nothing")
	assert_eq(grid.solid_count(), 100 - first.size())


func test_destroy_circle_clips_at_boundaries() -> void:
	var grid := TerrainGrid.new(5, 5, true)

	var destroyed := grid.destroy_circle(Vector2(0, 0), 2.0)

	assert_gt(destroyed.size(), 0)
	for cell in destroyed:
		assert_true(grid.is_inside(cell), "destroyed cells must stay inside the grid")
	assert_eq(grid.solid_count(), 25 - destroyed.size())


func test_destroy_circle_outside_the_grid_returns_nothing() -> void:
	var grid := TerrainGrid.new(5, 5, true)

	var destroyed := grid.destroy_circle(Vector2(-10, -10), 2.0)

	assert_eq(destroyed.size(), 0)
	assert_eq(grid.solid_count(), 25)


func test_destroy_circle_does_not_return_duplicates() -> void:
	var grid := TerrainGrid.new(10, 10, true)

	var destroyed := grid.destroy_circle(Vector2(5, 5), 3.0)
	var unique := {}
	for cell in destroyed:
		unique[cell] = true

	assert_eq(unique.size(), destroyed.size())
