# Proposal: destructible-terrain

## Why

La destrucción del escenario es la mecánica diferencial del juego y el mayor riesgo técnico del vertical slice. El jugador ya se mueve y salta, pero el suelo y las plataformas son cuerpos estáticos que no reaccionan a nada. Sin terreno destructible no se puede validar el combate ni el game feel de Broforce.

Este change introduce una grilla de celdas destructibles con colisión, representación visual y una explosión de prueba en la escena de depuración.

## What Changes

- Añadir una grilla pura de celdas de 8 px con estado sólido/vacío, límites y operaciones de relleno y destrucción circular.
- Crear un nodo de terreno destructible que renderice la grilla con tiles y actualice solo las celdas destruidas.
- Generar el `TileSet` en código con una capa de física y colisión por celda, sin depender de arte final.
- Sustituir el suelo y la plataforma estáticos de la escena de depuración por terreno destructible.
- Exponer una explosión que destruya celdas dentro de un radio y emita una señal con las celdas afectadas para futuros debris.
- Añadir un botón de depuración para detonar una explosión cerca del jugador.
- Cubrir la grilla con tests unitarios y el nodo/escena con tests de integración headless.

**Fuera de alcance:** armas, balas, enemigos, debris visuales, partículas, sonido, colapso estructural, terreno por píxeles y niveles completos.

## Capabilities

### New Capabilities

- `destructible-terrain`: grilla de celdas sólidas, destrucción circular por explosiones, representación por tiles, colisión actualizada y señal de destrucción.

### Modified Capabilities

Ninguna. `player-controller` no cambia: el jugador sigue usando `move_and_slide` contra la colisión del terreno.

## Impact

- **Nuevo:** `src/core/terrain_grid.gd`, `src/world/destructible_terrain.gd`, tests unitarios e integración.
- **Modificado:** `scenes/debug_session.tscn` (terreno en lugar de cuerpos estáticos, botón de explosión), `src/presentation/debug_session.gd`, `tests/integration/test_debug_session.gd`, `README.md`.
- **Sin cambios:** `project.godot`, `InputMap`, resolución y puerta de calidad.
- **Riesgo:** la configuración programática del `TileSet` y su polígono de colisión puede variar en Godot 4.7; se valida con un test de jugador apoyado sobre el terreno y un fallback documentado a un `TileSet` guardado si fuera necesario.
