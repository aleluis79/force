# Design: player-controller

## Context

La sesión ya funciona y la escena de depuración muestra su HUD. Falta un jugador que se mueva. El proyecto exige lógica pura en `src/core`, entrada inyectable y tests headless deterministas. Ver `proposal.md` y `specs/player-controller/spec.md`.

## Goals / Non-Goals

**Goals:**

- Movimiento y salto con game feel arcade, pero con parámetros centralizados.
- Lógica de movimiento testeable sin física ni escena.
- Entrada sustituible por una fuente guionizada en tests.
- Apuntado 360° y cámara con look-ahead.
- Playground mínimo dentro de la escena de depuración.

**Non-Goals:**

- Disparo, daño, salud, animaciones o sprites finales.
- Física de plataformas avanzada (paredes, techos, one-way platforms).
- Cámara con límites de nivel complejos o cinemáticas.
- Sonido o partículas.

## Decisions

### D1. `PlayerMotion` puro como `RefCounted`

`src/core/player_motion.gd` concentra velocidades, gravedad, salto, coyote time y jump buffer. No conoce `CharacterBody2D`, `Input` ni el árbol. Expone `tick(...)` y devuelve el vector de velocidad deseado.

```gdscript
func tick(
    delta: float,
    move_axis: float,
    jump_just_pressed: bool,
    jump_just_released: bool,
    grounded: bool
) -> Vector2
```

El nodo `Player` copia el resultado a `velocity`, llama a `move_and_slide()` y actualiza `motion.grounded` con `is_on_floor()`.

**Alternativas:** toda la física dentro de `_physics_process` (tests de integración lentos y frágiles), usar `move_and_slide` como fuente de verdad (no testeable en aislamiento).

### D2. Parámetros de movimiento

| Constante | Valor inicial |
|---|---|
| `MAX_SPEED` | `120.0` px/s |
| `ACCELERATION` | `900.0` px/s² |
| `DECELERATION` | `1200.0` px/s² |
| `GRAVITY` | `900.0` px/s² |
| `MAX_FALL_SPEED` | `400.0` px/s |
| `JUMP_VELOCITY` | `-300.0` px/s |
| `JUMP_CUT_MULTIPLIER` | `0.4` |
| `COYOTE_TIME` | `0.1` s |
| `JUMP_BUFFER_TIME` | `0.1` s |

Los valores son constantes de clase para que los tests y el ajuste manual hablen del mismo número. Se pueden convertir en recursos exportados cuando exista más de un personaje.

**Alternativas:** valores mágicos en el nodo (difíciles de testear), recursos por personaje (prematuro).

### D3. `InputSource` inyectable

`src/core/input_source.gd` es una clase base `RefCounted` con métodos por defecto neutros:

```gdscript
func get_move_axis() -> float
func was_jump_just_pressed() -> bool
func was_jump_just_released() -> bool
func get_aim_direction(origin: Vector2, pointer: Vector2) -> Vector2
```

`src/presentation/local_input_source.gd` implementa la versión real con `Input.get_axis`, `Input.is_action_just_pressed` y `Input.get_vector`. El jugador crea una instancia local en `_ready()` solo si no se inyectó una antes de entrar al árbol.

**Alternativas:** leer `Input` directamente en `Player` (imposible de testear sin teclado), usar autoload (estado global).

**Consecuencias:** los tests inyectan `ScriptedInputSource` antes de `add_child`; el `Player` no necesita saber si la entrada viene de teclado, gamepad o un guion.

### D4. Apuntado 360°

`LocalInputSource.get_aim_direction(origin, pointer)`:

1. Lee `Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")`.
2. Si la longitud supera `0.2`, devuelve el vector normalizado (gamepad).
3. Si no, calcula `pointer - origin`; si es distinto de cero, lo normaliza (ratón).
4. Si no hay entrada válida, devuelve `Vector2.RIGHT`.

El jugador guarda `aim_direction` y se lo pasa a la cámara. El apuntado con ratón usa la posición global del puntero que el nodo obtiene del viewport; la fuente solo recibe el vector ya transformado.

**Alternativas:** usar solo el ratón (injugable con gamepad), usar solo el stick (injugable con ratón).

### D5. Cámara hija con suavizado

`src/presentation/player_camera.gd` es un `Camera2D` hijo del jugador. Mantiene `target_offset` y en `_process` interpola `position` hacia `aim_direction * look_ahead_distance` con una velocidad de seguimiento.

- `look_ahead_distance = 32.0`
- `follow_speed = 8.0`

La cámara sigue al jugador por jerarquía; el offset añade el look-ahead. Los límites del nivel se configuran en la escena.

**Alternativas:** cámara independiente con script de seguimiento (más código), cámara fija (no funciona en niveles más anchos).

### D6. Playground dentro de la escena de depuración

`scenes/debug_session.tscn` se amplía con:

- Instancia de `scenes/player.tscn` en `(80, 200)`.
- `StaticBody2D` de suelo en `(240, 250)` con forma `480×32`.
- `StaticBody2D` de plataforma en `(220, 180)` con forma `96×16`.
- Rectángulos de color como visuales placeholder.

El HUD existente se mantiene en su `CanvasLayer`, por lo que la cámara no lo desplaza. No se cambia la escena principal ni `project.godot`.

**Alternativas:** crear una escena de nivel separada (duplica HUD y controlador), cambiar la escena principal (rompe el requisito de la spec de sesión).

### D7. Tests por capas

- `tests/unit/test_player_motion.gd`: aceleración, desaceleración, límite, gravedad, caída máxima, salto, recorte, coyote, buffer, reset.
- `tests/unit/test_input_source.gd`: valores neutros de la base y apuntado local con puntero.
- `tests/helpers/scripted_input_source.gd`: fuente guionizada para integración.
- `tests/integration/test_player.gd`: jugador sobre suelo, movimiento, salto y apuntado con entrada guionizada.
- `tests/integration/test_player_camera.gd`: objetivo de look-ahead y suavizado.
- `tests/integration/test_debug_session.gd`: se amplía para verificar jugador, suelo y HUD.

## Risks / Trade-offs

| Riesgo | Mitigación |
|---|---|
| La física se siente mal aunque los tests pasen | Constantes centralizadas y playground manual; ajustar después con playtest |
| `is_on_floor()` tarda un frame en estabilizarse | Los tests esperan varios frames de física antes de medir; el coyote time cubre el borde |
| Inyectar la fuente después de `_ready` no funciona | El test inyecta antes de `add_child`; el jugador solo crea la fuente local si es nula |
| El ratón en headless no tiene posición útil | Los tests usan `ScriptedInputSource`; el apuntado local se prueba con un puntero explícito |
| El HUD tapa al jugador | El HUD está en `CanvasLayer` y el jugador empieza abajo; se ajusta visualmente en el playground |
| La cámara con límites puede recortar el look-ahead | Los límites se configuran en la escena y se validan manualmente |

## Migration Plan

No hay datos. La escena de depuración se amplía; el jugador es un nodo nuevo. Rollback: eliminar los archivos nuevos y quitar la instancia de jugador, suelo y plataforma de la escena.

## Open Questions

Ninguna que afecte al alcance. El ajuste fino de velocidades y la animación se resolverán con playtest y el change de presentación.
