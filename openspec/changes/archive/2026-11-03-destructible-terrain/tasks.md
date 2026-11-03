# Tasks: destructible-terrain

## 1. Grilla pura

- [x] 1.1 Escribir primero `tests/unit/test_terrain_grid.gd` con límites, consulta, relleno de rectángulos, relleno parcial fuera de límites y conteo de sólidos; implementar `src/core/terrain_grid.gd` con `PackedByteArray`. Verificación: los tests pasan y fallan si se modifican celdas fuera de los límites.
- [x] 1.2 Ampliar el test con destrucción circular, explosión en borde, explosión sobre celdas vacías, idempotencia y celdas devueltas sin duplicados; completar `destroy_circle`. Verificación: cada escenario de destrucción tiene un test que pasa y falla si se devuelven celdas ya vacías.

## 2. Nodo de terreno

- [x] 2.1 Escribir primero `tests/integration/test_destructible_terrain.gd` (grilla inicial, render de tiles, explosión elimina tiles, señal con celdas y posición, señal omitida sin destrucción); implementar `src/world/destructible_terrain.gd` con `TileSet` programático de 8×8 y capa de física. Verificación: los tests pasan y no quedan tiles obsoletos tras la explosión.

## 3. Colisión y jugador

- [x] 3.1 Ampliar `tests/integration/test_destructible_terrain.gd` con un jugador que aterriza sobre el terreno y cae al destruir el suelo bajo sus pies; ajustar el polígono de colisión del `TileSet` si es necesario. Verificación: el jugador queda en `is_on_floor()` sobre terreno sólido y deja de estarlo tras la explosión.

## 4. Escena de depuración

- [x] 4.1 Sustituir el suelo y la plataforma estáticos de `scenes/debug_session.tscn` por el terreno destructible, añadir el botón **Explode** y conectarlo en `src/presentation/debug_session.gd`; ampliar `tests/integration/test_debug_session.gd` para verificar terreno, aterrizaje, explosión y HUD. Actualizar `README.md` con el control de explosión. Verificación: `./scripts/test.sh` pasa y la escena permite destruir terreno sin romper la sesión.

## 5. Cierre del change

- [x] 5.1 Borrar `.godot/`, ejecutar `./scripts/test.sh` desde cero y confirmar que toda la suite pasa, `openspec validate --all --strict` pasa y el código de salida es 0. Verificación: salida limpia, sin `SCRIPT ERROR`, con el resumen de tests y validación correctos.

## Workflow follow-up

- Revisar el diff completo y confirmar que no se implementaron armas, enemigos ni debris visuales fuera del alcance.
- Archivar el change con `/opsx-archive` cuando la revisión esté aprobada.
