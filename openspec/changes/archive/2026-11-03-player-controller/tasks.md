# Tasks: player-controller

## 1. Lógica pura de movimiento

- [x] 1.1 Escribir primero `tests/unit/test_player_motion.gd` con aceleración, desaceleración, límite de velocidad, gravedad y velocidad máxima de caída; implementar `src/core/player_motion.gd` con esas reglas. Verificación: los tests pasan y fallan si se supera el límite o no se aplica gravedad.
- [x] 1.2 Ampliar el test con salto desde suelo, recorte al soltar, ausencia de doble salto, coyote time, expiración de coyote, jump buffer, expiración de buffer y `reset()`; completar `PlayerMotion`. Verificación: cada escenario de salto, coyote y buffer tiene un test que pasa y falla al romper la ventana correspondiente.

## 2. Abstracción de entrada

- [x] 2.1 Escribir primero `tests/unit/test_input_source.gd` (valores neutros de la base, apuntado local por puntero, zona muerta y dirección por defecto) e implementar `src/core/input_source.gd` y `src/presentation/local_input_source.gd`. Verificación: los tests pasan y la implementación local usa las acciones `move_*`, `jump` y `aim_*` del `InputMap`.

## 3. Jugador y cámara

- [x] 3.1 Escribir `tests/helpers/scripted_input_source.gd` y primero `tests/integration/test_player.gd` (aterrizaje sobre suelo, movimiento con entrada guionizada, salto y apuntado); implementar `src/entities/player.gd` como `CharacterBody2D` con inyección de `InputSource` y `move_and_slide`. Verificación: el test pasa en headless y el jugador responde a la fuente guionizada sin usar teclado.
- [x] 3.2 Crear `src/presentation/player_camera.gd` y `scenes/player.tscn` con colisión, visual placeholder y cámara; escribir `tests/integration/test_player_camera.gd` para el objetivo de look-ahead y el suavizado. Verificación: los tests pasan y la cámara no salta instantáneamente al cambiar de dirección.

## 4. Playground de depuración

- [x] 4.1 Añadir el jugador, el suelo y la plataforma a `scenes/debug_session.tscn`; ampliar `tests/integration/test_debug_session.gd` para verificar que el jugador aterriza y que el HUD sigue funcionando; actualizar `README.md` con los controles de movimiento y salto. Verificación: `./scripts/test.sh` pasa y la escena de depuración es jugable con teclado, ratón o gamepad.

## 5. Cierre del change

- [x] 5.1 Borrar `.godot/`, ejecutar `./scripts/test.sh` desde cero y confirmar que toda la suite pasa, `openspec validate --all --strict` pasa y el código de salida es 0. Verificación: salida limpia, sin `SCRIPT ERROR`, con el resumen de tests y validación correctos.

## Workflow follow-up

- Revisar el diff completo y confirmar que no se implementó disparo, daño ni enemigos fuera del alcance.
- Archivar el change con `/opsx-archive` cuando la revisión esté aprobada.
