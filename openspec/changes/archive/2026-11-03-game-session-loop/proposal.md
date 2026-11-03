# Proposal: game-session-loop

## Why

La base del proyecto ya arranca, tiene tests headless y un `InputMap` estable, pero todavía no existe un bucle de sesión: no hay estados de partida, vidas, puntuación ni pausa/reinicio. Sin esa capa, el próximo gameplay no tendría dónde colgarse ni una forma observable de perder, puntuar o reiniciar.

Este change introduce el esqueleto de sesión que usarán el jugador, los enemigos y los niveles.

## What Changes

- Añadir una máquina de estados pura de sesión con los estados `READY`, `PLAYING`, `PAUSED` y `GAME_OVER`.
- Empezar cada partida con 3 vidas y 0 puntos; perder una vida en `PLAYING` y terminar en `GAME_OVER` al llegar a 0.
- Sumar puntuación solo mientras la partida está en `PLAYING`.
- Permitir pausar/reanudar con la acción `pause` y reiniciar con `restart`, reseteando vidas y puntuación.
- Añadir un controlador de sesión que conecta las acciones de entrada con la lógica pura y expone el estado a la presentación.
- Crear una escena de depuración con HUD de estado, vidas y puntuación, más botones para perder vida, sumar puntos y reiniciar.
- Convertir esa escena de depuración en la escena principal del proyecto.
- Cubrir la lógica con tests unitarios y la integración de entrada/escena con tests headless.

**Fuera de alcance:** jugador, movimiento, disparo, enemigos, terreno, rescates, niveles, menú principal, victoria, guardado, audio y arte final.

## Capabilities

### New Capabilities

- `game-session`: ciclo de vida de una partida arcade (estados, vidas, puntuación, pausa y reinicio) y su conexión con las acciones de entrada.

### Modified Capabilities

Ninguna. `project-foundation` no cambia: solo se sustituye la escena principal de placeholder por una escena de depuración funcional.

## Impact

- **Nuevo:** `src/core/game_session.gd`, `src/presentation/session_controller.gd`, `src/presentation/debug_session.gd`, `scenes/debug_session.tscn`, tests unitarios e de integración asociados.
- **Modificado:** `project.godot` (escena principal), `tests/unit/test_project_settings.gd` (nueva ruta de escena principal) y `README.md` (estado y controles de la escena de debug).
- **Sin cambios:** `src/core/deterministic_rng.gd`, la configuración de resolución, el `InputMap` y la puerta de calidad.
- **Riesgo:** que el controlador acople la lógica a `Input`; se mitiga manteniendo toda la lógica en `GameSession` y testeando el controlador por separado.
