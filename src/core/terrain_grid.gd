class_name TerrainGrid
extends RefCounted

## Pure destructible terrain grid.
##
## Each cell stores one byte (solid/empty) in a PackedByteArray. Cell
## coordinates are grid units; the node layer is responsible for converting
## world positions and tile sizes.

var width: int
var height: int

var _cells := PackedByteArray()


func _init(grid_width: int, grid_height: int, filled: bool = false) -> void:
	width = grid_width
	height = grid_height
	_cells.resize(width * height)
	if filled:
		_cells.fill(1)


func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < width and cell.y < height


func is_solid(cell: Vector2i) -> bool:
	if not is_inside(cell):
		return false
	return _cells[_index(cell)] == 1


func set_solid(cell: Vector2i, solid: bool) -> void:
	if not is_inside(cell):
		return

	var index := _index(cell)
	var value := 1 if solid else 0
	if _cells[index] == value:
		return
	_cells[index] = value


func fill_rect(rect: Rect2i, solid: bool = true) -> void:
	var start_x := maxi(rect.position.x, 0)
	var start_y := maxi(rect.position.y, 0)
	var end_x := mini(rect.position.x + rect.size.x, width)
	var end_y := mini(rect.position.y + rect.size.y, height)

	for y in range(start_y, end_y):
		for x in range(start_x, end_x):
			set_solid(Vector2i(x, y), solid)


func solid_count() -> int:
	var count := 0
	for value in _cells:
		count += value
	return count


func destroy_circle(center: Vector2, radius: float) -> Array[Vector2i]:
	var destroyed: Array[Vector2i] = []
	if radius <= 0.0:
		return destroyed

	var min_x := maxi(int(floor(center.x - radius)), 0)
	var max_x := mini(int(ceil(center.x + radius)), width - 1)
	var min_y := maxi(int(floor(center.y - radius)), 0)
	var max_y := mini(int(ceil(center.y + radius)), height - 1)
	var radius_squared := radius * radius

	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var cell := Vector2i(x, y)
			if not is_solid(cell):
				continue
			var cell_center := Vector2(x + 0.5, y + 0.5)
			if cell_center.distance_squared_to(center) <= radius_squared:
				set_solid(cell, false)
				destroyed.append(cell)

	return destroyed


func _index(cell: Vector2i) -> int:
	return cell.y * width + cell.x
