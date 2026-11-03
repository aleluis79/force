# Tasks: playable-slice

## 1. Sesión ampliada

- [x] 1.1 Ampliar `tests/unit/test_game_session.gd` con victoria desde `PLAYING`, victoria ignorada en otros estados, `add_life()` y reinicio desde `VICTORY`; implementar `State.VICTORY`, `win()`, `is_victory()` y `add_life()` en `GameSession`. Verificación: los tests pasan y el reinicio desde victoria deja `PLAYING` con 3 vidas y 0 puntos.

## 2. Enemigos

- [x] 2.1 Escribir primero `tests/integration/test_enemies.gd` (persecución del grunt, daño por contacto, kamikaze se mueve hacia el jugador, daño de bala, muerte y puntuación) e implementar `src/entities/grunt.gd`, `src/entities/kamikaze.gd`, `scenes/grunt.tscn` y `scenes/kamikaze.tscn`. Verificación: los tests pasan y ambos enemigos emiten `died(points)` al morir.

## 3. Rescates

- [x] 3.1 Escribir primero `tests/integration/test_rescue.gd` (rescate por contacto, +1 vida, +500 puntos, checkpoint, sin doble rescate) e implementar `src/entities/pow.gd` y `scenes/pow.tscn`. Verificación: los tests pasan y el POW desaparece una sola vez.

## 4. Muerte y reaparición del jugador

- [x] 4.1 Ampliar `tests/integration/test_player.gd` con daño, muerte, invulnerabilidad y `respawn`; implementar `alive`, `invulnerable`, `died`, `take_damage()` y `respawn()` en `Player`. Verificación: el jugador muere una vez, se oculta, reaparece en la posición indicada y no recibe daño durante la invulnerabilidad.

## 5. Nivel jugable y HUD

- [x] 5.1 Añadir `rebuild(width, height, ground_rows, platforms)` a `DestructibleTerrain` y un test que verifique el cambio de tamaño; implementar `src/level/level.gd`, `scenes/level_01.tscn` con terreno de 960 px, enemigos, POWs, salida y HUD. Verificación: el nivel carga, el jugador aterriza y el HUD muestra vidas, puntuación y arma.
- [x] 5.2 Escribir `tests/integration/test_level.gd` (carga, muerte/reaparición, rescate, victoria, game over, reinicio y HUD) y conectar las señales del nivel; cambiar `application/run/main_scene` a `res://scenes/level_01.tscn` y actualizar `tests/unit/test_project_settings.gd`. Verificación: los tests del nivel pasan y la escena principal es el nivel.
- [x] 5.3 Actualizar `README.md` con el nivel, controles, objetivo y estado del slice. Verificación: las instrucciones del README permiten ejecutar y completar el nivel.

## 6. Cierre

- [x] 6.1 Borrar `.godot/`, ejecutar `./scripts/test.sh` desde cero y confirmar suite, `openspec validate --all --strict` y salida 0. Verificación: salida limpia sin `SCRIPT ERROR` ni fugas de recursos.

## Workflow follow-up

- Revisar el diff completo y confirmar que el juego se puede jugar de principio a fin.
- Archivar el change con `/opsx-archive`.
