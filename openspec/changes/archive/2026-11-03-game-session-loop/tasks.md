# Tasks: game-session-loop

## 1. Lógica pura de sesión

- [x] 1.1 Escribir primero `tests/unit/test_game_session.gd` con estado inicial (`READY`, 3 vidas, 0 puntos), `start()`, `pause()`, `resume()`, `toggle_pause()` y transiciones inválidas; ejecutarlo en rojo e implementar `src/core/game_session.gd` con el enum `State` y las señales base. Verificación: los tests pasan y fallan si se permite una transición inválida.
- [x] 1.2 Ampliar `tests/unit/test_game_session.gd` con pérdida de vidas, `GAME_OVER`, límite en 0, puntuación solo en `PLAYING`, reinicio desde cualquier estado y emisión de señales; implementar el resto de `GameSession`. Verificación: los tests pasan y cubren cada escenario de `game-session` sobre vidas, puntos, reinicio y señales.

## 2. Controlador de entrada

- [x] 2.1 Escribir primero `tests/integration/test_session_controller.gd` (autostart activado/desactivado, evento `pause` alterna, evento `restart` reinicia con 3 vidas y 0 puntos); implementar `src/presentation/session_controller.gd` con `_unhandled_input` y `session`. Verificación: el test pasa usando `InputEventKey` reales y falla si el evento no coincide con el `InputMap`.

## 3. Escena de depuración y HUD

- [x] 3.1 Crear `src/presentation/debug_session.gd` y `scenes/debug_session.tscn` con etiquetas de estado/vidas/puntuación y botones "Lose life", "Add 100" y "Restart"; escribir `tests/integration/test_debug_session.gd` que valide el HUD inicial, las acciones de los botones y la actualización de etiquetas. Verificación: el test de escena pasa en headless y el HUD refleja cada cambio.
- [x] 3.2 Cambiar `application/run/main_scene` a `res://scenes/debug_session.tscn`, actualizar `tests/unit/test_project_settings.gd` y `README.md` con la escena y los controles nuevos. Verificación: `./scripts/test.sh` pasa y la escena principal carga en headless con el HUD en `PLAYING`, 3 vidas y 0 puntos.

## 4. Cierre del change

- [x] 4.1 Borrar `.godot/`, ejecutar `./scripts/test.sh` desde cero y confirmar que toda la suite pasa, `openspec validate --all --strict` pasa y el código de salida es 0. Verificación: salida limpia, sin `SCRIPT ERROR`, con el resumen de tests y validación correctos.

## Workflow follow-up

- Revisar el diff completo y confirmar que no se implementó gameplay fuera del alcance.
- Archivar el change con `/opsx-archive` cuando la revisión esté aprobada.
