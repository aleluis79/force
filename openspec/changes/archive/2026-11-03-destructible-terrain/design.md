# Design: destructible-terrain

## Context

El jugador ya se mueve sobre cuerpos estáticos. La destrucción es la mecánica diferencial y el riesgo técnico principal. Ver `proposal.md` y `specs/destructible-terrain/spec.md`.

Restricciones:

- La grilla y la destrucción deben ser lógica pura, testeable sin nodos.
- La representación debe usar celdas de 8 px y el `TileSet` debe generar colisión real.
- No hay arte final; el tile se genera en código con un color plano.
- La puerta de calidad debe seguir siendo rápida y headless.

## Goals / Non-Goals

**Goals:**

- Grilla compacta y determinista con destrucción circular.
- Nodo de terreno que renderice y actualice solo celdas afectadas.
- Colisión por celda para que el jugador se apoye y caiga al destruir.
- Señal de destrucción para conectar debris/partículas después.
- Escena de debug con botón de explosión.

**Non-Goals:**

- Armas, balas, enemigos, daño o debris visual.
- Colapso estructural o simulación de escombros.
- Destrucción por píxeles o terreno procedural complejo.
- Chunking o `MultiMesh`; se evalúa solo si el rendimiento lo exige.

## Decisions

### D1. `TerrainGrid` puro con `PackedByteArray`

`src/core/terrain_grid.gd` guarda un byte por celda en un `PackedByteArray` de `width * height`. El índice es `y * width + x`. No conoce nodos, tiles ni posiciones mundiales.

API:

```gdscript
func _init(width: int, height: int, filled: bool = false)
func is_inside(cell: Vector2i) -> bool
func is_solid(cell: Vector2i) -> bool
func set_solid(cell: Vector2i, solid: bool) -> void
func fill_rect(rect: Rect2i, solid: bool = true) -> void
func solid_count() -> int
func destroy_circle(center: Vector2, radius: float) -> Array[Vector2i]
```

`destroy_circle` recibe el centro y el radio en unidades de celda (no píxeles), recorre el bounding box, compara la distancia al centro de cada celda (`Vector2(x + 0.5, y + 0.5)`) y devuelve solo las celdas que pasaron de sólidas a vacías.

**Alternativas:** `Dictionary[Vector2i, bool]` (más memoria y más lento), matriz de `Array` (peor localidad), píxeles (demasiado coste para el slice).

**Consecuencias:** la grilla es determinista, rápida y fácil de serializar en el futuro.

### D2. `DestructibleTerrain` como `TileMapLayer`

`src/world/destructible_terrain.gd` extiende `TileMapLayer` y:

1. Crea la grilla con `width = 60`, `height = 34` (480×272 px).
2. Rellena las 6 filas inferiores como suelo.
3. Rellena una plataforma en `Rect2i(22, 22, 14, 2)`.
4. Construye un `TileSet` programático de 8×8.
5. Renderiza las celdas sólidas con `set_cell`.
6. Expone `explode(world_position: Vector2, radius: float) -> Array[Vector2i]`.

La conversión mundial → celda es `world_position / TILE_SIZE`; el radio se divide por `TILE_SIZE` para trabajar en unidades de celda.

**Alternativas:** `TileMap` clásico (Godot 4.7 recomienda `TileMapLayer`), `MultiMesh` (más control pero más código), cuerpos estáticos por celda (inviable).

### D3. `TileSet` programático con colisión

El `TileSet` se construye en `_ready()`:

```gdscript
var image := Image.create(8, 8, false, Image.FORMAT_RGBA8)
image.fill(Color(0.18, 0.2, 0.26))
var texture := ImageTexture.create_from_image(image)

var tile_set := TileSet.new()
tile_set.tile_size = Vector2i(8, 8)
tile_set.add_physics_layer()
tile_set.set_physics_layer_collision_layer(0, 1)

var source := TileSetAtlasSource.new()
source.texture = texture
source.texture_region_size = Vector2i(8, 8)
source.create_tile(Vector2i.ZERO)
var data := source.get_tile_data(Vector2i.ZERO, 0)
data.add_collision_polygon(0)
data.set_collision_polygon_points(0, 0, PackedVector2Array([
    Vector2(-4, -4), Vector2(4, -4), Vector2(4, 4), Vector2(-4, 4),
]))
tile_set.add_source(source, 0)
```

El polígono se expresa relativo al centro del tile. Si Godot 4.7 cambia la API o la convención, el test de jugador apoyado sobre el terreno lo detecta; el fallback es un `TileSet` guardado como `.tres` con una textura `.png`.

**Alternativas:** `TileSet` en editor (requiere arte y pasos manuales), colisión por `StaticBody2D` separado (no se actualiza al destruir).

### D4. Actualización incremental

`explode()` recibe las celdas destruidas por la grilla y llama `erase_cell(cell)` solo para esas celdas. No reconstruye el mapa ni recorre toda la grilla. Con 60×34 = 2040 celdas, el coste máximo de una explosión es acotado.

La señal `terrain_destroyed(cells, world_position)` se emite solo si `cells` no está vacío. La presentación futura conectará debris y partículas a esa señal.

**Alternativas:** reconstruir el `TileMapLayer` completo (simple pero caro), chunks sucios (prematuro para 2040 celdas), actualizar en un hilo (complejidad innecesaria).

### D5. Escena de depuración

`scenes/debug_session.tscn` sustituye los `StaticBody2D` de suelo y plataforma por un nodo `Terrain` (`TileMapLayer` con `destructible_terrain.gd`). El jugador aparece sobre el suelo generado.

Se añade un botón **Explode** que llama:

```gdscript
terrain.explode(player.global_position + player.aim_direction * 24.0, 24.0)
```

El HUD de sesión se mantiene. El botón es solo de depuración; las armas reales llegan en el siguiente change.

**Alternativas:** explosión automática al iniciar (no demuestra interacción), tecla nueva en `InputMap` (contamina el mapa de juego), botón en un panel separado (más UI).

### D6. Tests

- `tests/unit/test_terrain_grid.gd`: límites, relleno, conteo, destrucción circular, borde, idempotencia, celdas devueltas una sola vez.
- `tests/integration/test_destructible_terrain.gd`: construcción del `TileSet`, render inicial, explosión elimina tiles, señal, colisión con jugador y caída al destruir el suelo.
- `tests/integration/test_debug_session.gd`: terreno presente, jugador apoyado, botón de explosión destruye celdas y el HUD sigue funcionando.

No se mide tiempo en CI para evitar tests frágiles; el rendimiento se revisa manualmente en el playground con explosiones repetidas.

## Risks / Trade-offs

| Riesgo | Mitigación |
|---|---|
| La API de colisión del `TileSet` cambia en 4.7 | Test de jugador apoyado; fallback a `TileSet` guardado |
| El polígono de colisión usa coordenadas inesperadas | Verificación temprana con el test de aterrizaje; ajustar puntos |
| El jugador atraviesa el terreno a alta velocidad | `CharacterBody2D` con `move_and_slide`; celdas de 8 px y velocidad máxima 120 px/s; test de aterrizaje |
| La explosión deja tiles obsoletos | Test que verifica `get_cell_source_id(cell) == -1` tras destruir |
| El botón de explosión destruye el suelo bajo el jugador y lo hace caer | Comportamiento esperado; el jugador reaparece con reinicio |
| Actualizar muchas celdas en una explosión grande | Poda por bounding box y solo celdas sólidas; benchmark manual |
| El `TileSet` programático no se ve en el editor | Se genera en `_ready`; el editor muestra el nodo sin tiles hasta ejecutar, aceptable para el slice |

## Migration Plan

No hay datos. Se eliminan los `StaticBody2D` de suelo/plataforma de la escena de depuración y se añade el terreno. Rollback: restaurar los cuerpos estáticos y eliminar los archivos nuevos.

## Open Questions

Ninguna que afecte al alcance. El arte del tile y los debris visuales se resuelven en el change de presentación.
