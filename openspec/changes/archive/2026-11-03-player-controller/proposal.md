# Proposal: player-controller

## Why

Ya existe un bucle de sesión con vidas, puntuación, pausa y reinicio, pero no hay un jugador que mover. Sin un controlador ágil y testeable, el resto del vertical slice (armas, enemigos, destrucción) no se puede probar ni ajustar.

Este change introduce el movimiento base del jugador y una escena jugable mínima.

## What Changes

- Añadir una lógica pura de movimiento con aceleración/desaceleración horizontal, gravedad, velocidad máxima de caída y salto variable.
- Implementar coyote time y jump buffer con ventanas configurables.
- Abstraer la entrada en un `InputSource` inyectable, con una implementación local basada en `Input` y una implementación guionizada para tests.
- Crear un `Player` (`CharacterBody2D`) que consulte el `InputSource`, aplique la lógica pura y mueva el cuerpo con `move_and_slide`.
- Exponer apuntado 360° normalizado desde ratón o stick derecho.
- Añadir una cámara que sigue al jugador con look-ahead en la dirección de apuntado.
- Convertir la escena de depuración de sesión en un pequeño playground con suelo, plataforma y jugador, manteniendo el HUD y los controles de sesión.
- Cubrir movimiento, salto, entrada, jugador y cámara con tests unitarios e integración headless.

**Fuera de alcance:** disparo, daño, salud, animaciones, sprites finales, enemigos, terreno destructible, niveles completos y sonido.

## Capabilities

### New Capabilities

- `player-controller`: movimiento horizontal, salto con coyote time y jump buffer, apuntado 360°, abstracción de entrada y seguimiento de cámara del jugador.

### Modified Capabilities

Ninguna. `game-session` conserva su comportamiento; la escena de depuración sigue mostrando el HUD y añade el jugador.

## Impact

- **Nuevo:** `src/core/player_motion.gd`, `src/core/input_source.gd`, `src/presentation/local_input_source.gd`, `src/entities/player.gd`, `src/presentation/player_camera.gd`, `scenes/player.tscn`, tests unitarios e integración.
- **Modificado:** `scenes/debug_session.tscn` (jugador, suelo y plataforma), `tests/integration/test_debug_session.gd`, `README.md`.
- **Sin cambios:** `project.godot` (la escena principal sigue siendo `debug_session.tscn`), `InputMap`, resolución y puerta de calidad.
- **Riesgo:** el ajuste de física puede sentirse mal aunque los tests pasen; se mitiga con parámetros centralizados y una comprobación manual del playground.
