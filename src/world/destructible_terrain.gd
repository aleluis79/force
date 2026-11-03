class_name DestructibleTerrain
extends TileMapLayer

## TileMapLayer adapter for the pure TerrainGrid.
##
## Builds a placeholder TileSet with physics collision in code so the
## playground can be destroyed without final art assets.

signal terrain_destroyed(cells: Array, world_position: Vector2)

const TILE_SIZE := 8
const WIDTH := 60
const HEIGHT := 34
const GROUND_ROWS := 6
const PLATFORM_RECT := Rect2i(22, 22, 14, 2)

var grid: TerrainGrid


func _ready() -> void:
	add_to_group("terrain")
	_build_grid()
	_build_tile_set()
	_render_all()


func is_solid_at_world(world_position: Vector2) -> bool:
	if grid == null:
		return false
	var cell := Vector2i(
		floori(world_position.x / float(TILE_SIZE)),
		floori(world_position.y / float(TILE_SIZE))
	)
	return grid.is_solid(cell)


func get_solid_cell_count() -> int:
	if grid == null:
		return 0
	return grid.solid_count()


func explode(world_position: Vector2, radius: float) -> Array[Vector2i]:
	if grid == null:
		return []

	var center := world_position / float(TILE_SIZE)
	var destroyed := grid.destroy_circle(center, radius / float(TILE_SIZE))

	for cell in destroyed:
		erase_cell(cell)

	if not destroyed.is_empty():
		terrain_destroyed.emit(destroyed, world_position)

	return destroyed


func _build_grid() -> void:
	grid = TerrainGrid.new(WIDTH, HEIGHT)
	grid.fill_rect(Rect2i(0, HEIGHT - GROUND_ROWS, WIDTH, GROUND_ROWS))
	grid.fill_rect(PLATFORM_RECT)


func _build_tile_set() -> void:
	var image := Image.create(TILE_SIZE, TILE_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.18, 0.2, 0.26))

	var texture := ImageTexture.create_from_image(image)

	var new_tile_set := TileSet.new()
	new_tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	new_tile_set.add_physics_layer()
	new_tile_set.set_physics_layer_collision_layer(0, 1)

	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	source.create_tile(Vector2i.ZERO)
	new_tile_set.add_source(source, 0)

	var tile_data := source.get_tile_data(Vector2i.ZERO, 0)
	tile_data.add_collision_polygon(0)
	tile_data.set_collision_polygon_points(0, 0, PackedVector2Array([
		Vector2(-4, -4),
		Vector2(4, -4),
		Vector2(4, 4),
		Vector2(-4, 4),
	]))

	tile_set = new_tile_set


func _render_all() -> void:
	for y in range(HEIGHT):
		for x in range(WIDTH):
			var cell := Vector2i(x, y)
			if grid.is_solid(cell):
				set_cell(cell, 0, Vector2i.ZERO, 0)
