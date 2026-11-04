# Design: fix-enemy-facing

## Context

La spec de `presentation` exige que los enemigos miren hacia su dirección de persecución. La implementación usaba el sentido contrario porque el arte original del soldado mira a la izquierda.

## Decisions

### D1. Soldado con arte base hacia la izquierda

`Grunt` usa `_sprite.flip_h = facing_direction > 0.1`. Cuando persigue a la izquierda (`facing_direction < 0`), no se voltea; cuando persigue a la derecha, se voltea.

### D2. Misil del kamikaze

El sprite del misil apunta a la izquierda. Se marca `flip_h = true` en la escena para que apunte a la derecha; la rotación `direction.angle()` ya existente pasa a alinear el morro con el movimiento.

### D3. Tests

- Grunt persiguiendo a la izquierda: `flip_h == false`.
- Grunt persiguiendo a la derecha: `flip_h == true`.
- Kamikaze: rotación alineada con la dirección al jugador y sprite volteado.

## Risks / Trade-offs

| Riesgo | Mitigación |
|---|---|
| Otros sprites del pack tengan distinta orientación base | Se documenta la orientación de cada sprite; tests por enemigo |
| El flip del kamikaze afecte la rotación | `flip_h` es local al Sprite2D y no cambia la rotación del Area2D |

## Migration Plan

Cambios locales; rollback inmediato.
