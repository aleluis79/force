# Design: game-session-loop

## Context

La base ya ofrece proyecto Godot 4.7.2, GUT, `InputMap` y una separación estricta de `src/core`. Falta el bucle de sesión. Ver `proposal.md` para la motivación y `specs/game-session/spec.md` para el comportamiento exigido.

Restricciones:

- La lógica de vidas, puntuación y estados debe ser pura y testeable sin árbol de escena.
- La entrada global (`Input`) solo puede usarse en la capa de presentación.
- El HUD debe ser observable en headless mediante señales y propiedades, no comparando píxeles.
- No hay gameplay todavía; pausar no debe congelar el árbol de escena porque no hay nada que congelar y complicaría los tests.

## Goals / Non-Goals

**Goals:**

- Una máquina de estados de sesión pequeña, determinista y testeable.
- Un controlador que conecte `pause`/`restart` con la sesión.
- Una escena de depuración que haga visible el estado y permita probar vidas, puntos y reinicio.
- Tests unitarios de todas las transiciones y tests de integración de entrada y escena.

**Non-Goals:**

- Pausar el árbol de escena o congelar física.
- Menú principal, victoria, guardado o progresión.
- Implementar jugador, enemigos o niveles.
- Añadir acciones nuevas al `InputMap`.

## Decisions

### D1. `GameSession` puro como `RefCounted`

`src/core/game_session.gd` contiene el enum `State`, las vidas, la puntuación y las transiciones. No conoce `Node`, `Input`, autoloads ni el árbol de escena. Emite señales (`state_changed`, `lives_changed`, `score_changed`) para que la presentación se actualice sin acoplarse.

**Alternativas:** un `Node` de sesión (tests más lentos y dependientes del árbol), un autoload global (estado oculto y difícil de aislar).

**Consecuencias:** los tests unitarios instancian la clase directamente; el controlador y el HUD solo observan.

### D2. Transiciones explícitas e idempotentes

Cada método valida su estado de origen:

| Método | Origen válido | Destino |
|---|---|---|
| `start()` | `READY` | `PLAYING` |
| `pause()` | `PLAYING` | `PAUSED` |
| `resume()` | `PAUSED` | `PLAYING` |
| `toggle_pause()` | `PLAYING` / `PAUSED` | alterna |
| `lose_life()` | `PLAYING` | `PLAYING` o `GAME_OVER` |
| `add_score(points)` | `PLAYING` y `points > 0` | sin cambio de estado |
| `restart()` | cualquiera | `PLAYING` con 3 vidas y 0 puntos |

Las transiciones inválidas son no-op y no emiten señales. Esto evita condiciones de carrera cuando la entrada llega en un estado inesperado.

**Alternativas:** permitir cualquier transición y corregir en la presentación (errores silenciosos), usar excepciones (GDScript no las tiene de forma idiomática).

### D3. Señales con tipos primitivos

Las señales usan `int` para estados y valores:

```gdscript
signal state_changed(previous: int, current: int)
signal lives_changed(lives: int)
signal score_changed(score: int)
```

Los enums de GDScript son enteros; usar `int` evita problemas de tipado en señales y facilita los tests.

**Alternativas:** señales sin argumentos (la UI consulta propiedades), señales tipadas con el enum (más frágiles en GDScript).

### D4. Controlador en la capa de presentación

`src/presentation/session_controller.gd` es un `Node` que:

- Crea una `GameSession` en `_ready()`.
- Inicia la sesión si `autostart` es verdadero (por defecto).
- Escucha `_unhandled_input(event)` y traduce `event.is_action_pressed("pause")` a `toggle_pause()` y `restart` a `restart()`.
- Expone `session` para que el HUD se conecte.

No se usa `_process` con `Input.is_action_just_pressed` porque es más difícil de testear de forma determinista. El evento se puede construir con un `InputEventKey` real y pasarlo al método en el test, verificando también que el `InputMap` lo reconoce.

**Alternativas:** `_input` (puede ser consumido por UI), autoload (global), polling en `_process` (dependiente del frame).

### D5. La pausa es un estado, no una pausa del árbol

`PAUSED` solo cambia el estado de la sesión. El futuro gameplay consultará `session.is_playing()` para detener su simulación. Pausar `get_tree().paused` ahora obligaría a marcar HUD y controlador como `PROCESS_MODE_ALWAYS`, complicaría los tests y no aporta nada sin gameplay.

**Alternativas:** pausar el árbol ya (más "real" pero prematuro), congelar manualmente cada nodo (acoplamiento).

### D6. Escena de depuración como escena principal

`scenes/debug_session.tscn` contiene:

- Raíz `DebugSession` con `src/presentation/debug_session.gd`.
- Nodo hijo `SessionController`.
- `CanvasLayer` con etiquetas de estado/vidas/puntuación y botones "Lose life", "Add 100" y "Restart".

La escena se convierte en `application/run/main_scene`. `scenes/bootstrap.tscn` se conserva como fixture del smoke test de la fundación. El test de configuración se actualiza para esperar la nueva escena principal.

**Alternativas:** mantener bootstrap como principal y ejecutar el debug con `--scene` (peor experiencia), añadir un menú (fuera de alcance).

### D7. Tests por capas

- **Unitarios:** `tests/unit/test_game_session.gd` cubre todas las transiciones, vidas, puntos, reinicio y señales.
- **Integración de controlador:** `tests/integration/test_session_controller.gd` instancia el controlador, envía eventos de pausa/reinicio y verifica el estado.
- **Integración de escena:** `tests/integration/test_debug_session.gd` carga la escena, verifica el HUD inicial, pulsa los botones por código y comprueba que el HUD se actualiza.

No se testean posiciones de píxeles ni estilos visuales.

## Risks / Trade-offs

| Riesgo | Mitigación |
|---|---|
| El HUD se conecta antes de que el controlador cree la sesión | El controlador es hijo y su `_ready()` corre antes que el de la raíz; el test de escena lo verifica |
| `event.is_action_pressed` no coincide con el `InputMap` en headless | El test construye un `InputEventKey` real con el keycode de pausa/reinicio y verifica el resultado |
| La escena principal cambia y rompe el test de fundación | Se actualiza `test_project_settings.gd` en la misma task que cambia la escena |
| El botón de reinicio compite con la acción `restart` | Los botones llaman directamente a `session.restart()`; la entrada global sigue funcionando |
| Pausa sin gameplay puede parecer incompleta | Se documenta que `PAUSED` es un estado de sesión y que el gameplay lo consumirá en el siguiente change |
| Señales con `int` pierden legibilidad | El HUD usa `GameSession.State.keys()[state]` para mostrar el nombre |

## Migration Plan

No hay datos ni usuarios. La escena principal cambia de `bootstrap.tscn` a `debug_session.tscn`; el smoke test de fundación sigue usando `bootstrap.tscn` directamente. Rollback: restaurar la escena principal y eliminar los archivos nuevos.

## Open Questions

Ninguna que afecte al alcance. El estilo visual definitivo del HUD se decide en el change de presentación.
