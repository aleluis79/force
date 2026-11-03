# Proposal: playable-slice

## Why

Ya existen movimiento, combate, terreno destructible y sesión, pero no hay un objetivo de juego: no hay enemigos, rescates, nivel ni condición de victoria. Sin este bloque el proyecto no es jugable de principio a fin.

## What Changes

- Añadir dos enemigos: un soldado que persigue y un kamikaze volador; ambos dañan al jugador al contacto, reciben daño de balas y otorgan puntuación al morir.
- Añadir prisioneros (POW) rescatables que dan una vida extra, puntuación y actualizan el checkpoint.
- Implementar muerte del jugador, pérdida de vida, reaparición con invulnerabilidad breve y game over.
- Ampliar la sesión con estado `VICTORY` y vidas extra.
- Crear un nivel jugable de 960×272 con terreno destructible, plataformas, enemigos, POWs y una salida.
- Añadir HUD de vidas, puntuación, arma y mensajes de pausa/game over/victoria.
- Convertir el nivel en la escena principal y mantener la escena de debug como banco de pruebas.
- Cubrir enemigos, rescates, nivel, HUD y flujo de victoria/derrota con tests headless.

**Fuera de alcance:** jefes, múltiples niveles, guardado, progresión persistente, arte/audio final, editor de niveles.

## Capabilities

### New Capabilities

- `enemies`: enemigos con IA simple, daño por contacto, salud y puntuación.
- `rescue-system`: prisioneros rescatables, vida extra, puntuación y checkpoint.
- `level-flow`: nivel jugable, muerte/reaparición, salida, victoria, game over, pausa y reinicio.

### Modified Capabilities

- `game-session`: se añade el estado de victoria y la vida extra.

## Impact

- **Nuevo:** `src/entities/grunt.gd`, `src/entities/kamikaze.gd`, `src/entities/pow.gd`, `src/level/level.gd`, `scenes/grunt.tscn`, `scenes/kamikaze.tscn`, `scenes/pow.tscn`, `scenes/level_01.tscn`, tests.
- **Modificado:** `src/core/game_session.gd`, `src/entities/player.gd`, `src/world/destructible_terrain.gd`, `scenes/player.tscn`, `scenes/debug_session.tscn`, `project.godot`, `tests/unit/test_project_settings.gd`, `README.md`.
- **Riesgo:** el equilibrio de dificultad y la estabilidad de la reaparición; se mitiga con invulnerabilidad, checkpoint y tests de flujo.
