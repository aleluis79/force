# Tasks: combat-weapons

## 1. Salud y daño

- [x] 1.1 Escribir primero `tests/unit/test_health.gd` (daño, daño letal, daño inválido, señales) e implementar `src/core/health.gd`. Verificación: los tests pasan y la salud nunca queda negativa.

## 2. Armas y cadencia

- [x] 2.1 Escribir primero `tests/unit/test_weapon_state.gd` (rifle automático, escopeta semiautomática, cooldown, dispersión determinista, cambio de arma) e implementar `src/core/weapon_stats.gd` y `src/core/weapon_state.gd`. Verificación: los tests pasan y la escopeta no dispara en ráfaga al mantener el botón.

## 3. Balas y pooling

- [x] 3.1 Escribir primero `tests/integration/test_bullet_pool.gd` (spawn, reutilización, límite de activas, expiración) e implementar `src/entities/bullet.gd` y `src/entities/bullet_pool.gd` con raycast a objetivos y comprobación de terreno. Verificación: los tests pasan y no quedan balas procesándose al terminar.

## 4. Integración de combate

- [x] 4.1 Ampliar `InputSource`/`LocalInputSource`/`ScriptedInputSource` con disparo; escribir primero `tests/integration/test_combat.gd` (disparo en la dirección de apuntado, impacto en dummy, impacto en terreno, retroceso) e integrar `WeaponState` y `BulletPool` en `Player`/`player.tscn`. Verificación: el jugador dispara, daña al dummy, destruye terreno y recibe retroceso.
- [x] 4.2 Crear `src/entities/training_dummy.gd` y `scenes/training_dummy.tscn`; escribir `tests/integration/test_training_dummy.gd` (daño, muerte, deja de ser dañable). Verificación: el dummy pierde salud y se oculta al morir.
- [x] 4.3 Crear `src/presentation/hit_stop.gd` y `tests/integration/test_hit_stop.gd`; conectar `hit_confirmed` del pool al hitstop en la escena de debug. Verificación: la escala de tiempo baja y vuelve a 1.0 tras el impacto.

## 5. Escena de depuración y cierre

- [x] 5.1 Añadir el dummy y los botones **Rifle**/**Shotgun** a `scenes/debug_session.tscn`, actualizar `src/presentation/debug_session.gd` y `tests/integration/test_debug_session.gd`; actualizar `README.md` con los controles de disparo y cambio de arma. Verificación: `./scripts/test.sh` pasa y se puede disparar y cambiar de arma en la escena.
- [x] 5.2 Borrar `.godot/`, ejecutar `./scripts/test.sh` desde cero y confirmar suite, `openspec validate --all --strict` y salida 0. Verificación: salida limpia sin `SCRIPT ERROR` ni fugas de recursos.

## Workflow follow-up

- Revisar el diff completo y confirmar que no se implementaron enemigos ni niveles fuera del alcance.
- Archivar el change con `/opsx-archive`.
