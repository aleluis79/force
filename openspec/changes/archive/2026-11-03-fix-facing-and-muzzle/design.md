# Design: fix-facing-and-muzzle

## Context

Los sprites ya existen y el combate funciona, pero la orientación y el origen de las balas no coinciden con la lectura visual. Ver `proposal.md` y las specs.

## Goals / Non-Goals

**Goals:** orientación coherente con movimiento/apuntado y balas desde el arma.

**Non-Goals:** animaciones nuevas, cambios de daño/cadencia o rebalanceo.

## Decisions

### D1. Orientación del jugador

`Player._update_sprite()` prioriza:

1. Eje de movimiento (`input_source.get_move_axis()`): si no es cero, mira hacia ese lado.
2. Velocidad horizontal: si se está moviendo por inercia, mira hacia la velocidad.
3. Apuntado: si está quieto, mira hacia `aim_direction.x`.

Se usa `Sprite2D.flip_h`; la hoja de sprites mira a la derecha por defecto.

### D2. Orientación del enemigo

`Grunt` calcula `direction = signf(player.x - grunt.x)` y usa ese valor para `flip_h`, no `velocity.x`. Así sigue mirando hacia el jugador aunque una pared o el terreno lo bloqueen.

### D3. Origen del proyectil

El arma está a la altura del pecho del sprite. Se define:

```gdscript
const MUZZLE_HEIGHT := -6.0
const MUZZLE_FORWARD := 6.0
const MUZZLE_EXTENSION := 10.0
```

`muzzle_origin = global_position + Vector2(MUZZLE_FORWARD * facing, MUZZLE_HEIGHT)` y `muzzle_position = muzzle_origin + aim_direction * MUZZLE_EXTENSION`, con `facing = sign(aim_direction.x)` (positivo si apunta a la derecha).

Esto mantiene el origen a la altura del arma y lo desplaza en la dirección de apuntado, en lugar de nacer en el centro del cuerpo.

### D4. Tests

- `test_player.gd`: el sprite se voltea al moverse a izquierda/derecha y al apuntar quieto.
- `test_enemies.gd`: el grunt mira a la izquierda cuando persigue a un jugador a su izquierda.
- `test_combat.gd`: las balas nacen por encima del centro y del lado del apuntado; apuntando arriba, nacen claramente arriba.

## Risks / Trade-offs

| Riesgo | Mitigación |
|---|---|
| El offset del arma no coincide exactamente con el píxel del arma | Constantes centralizadas; ajuste visual posterior |
| El jugador mira al apuntado mientras retrocede | Se prioriza el movimiento, que es lo que espera el jugador |
| El enemigo bloqueado mira raro | Mira a su objetivo, no a la pared; es intencional |

## Migration Plan

No hay datos. Cambios locales en scripts y tests. Rollback: revertir los métodos de orientación y el cálculo del muzzle.

## Open Questions

Ninguna.
