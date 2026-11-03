# Design: combat-weapons

## Context

Hay movimiento, apuntado y terreno destructible. Falta convertir el apuntado en disparos y validar daño. Ver `proposal.md` y `specs/combat/spec.md`.

## Goals / Non-Goals

**Goals:** salud/daño puros, rifle y escopeta, disparo con cooldown y retroceso, balas con pooling, impacto en objetivos y terreno, hitstop y objetivo de práctica.

**Non-Goals:** enemigos con IA, munición limitada, recarga, armas especiales, arte/audio final.

## Decisions

### D1. `Health` puro

`src/core/health.gd` (`RefCounted`) guarda `max_health` y `current`, emite `damaged(amount, current)` y `died`. `damage(amount)` ignora valores no positivos, recorta al máximo disponible y devuelve el daño aplicado. El jugador, enemigos y dummy lo reutilizan.

### D2. `WeaponStats` y `WeaponState`

`WeaponStats` (`RefCounted`) define `id`, `damage`, `shots_per_second`, `projectile_count`, `spread_degrees`, `bullet_speed`, `bullet_lifetime`, `terrain_radius`, `automatic` y `recoil`. Factories `rifle()` y `shotgun()`:

| Arma | Daño | Cadencia | Proyectiles | Dispersión | Vida bala | Radio terreno | Auto | Retroceso |
|---|---|---|---|---|---|---|---|---|
| rifle | 10 | 8/s | 1 | 2° | 0.8 s | 12 px | sí | 20 |
| escopeta | 6 | 1.5/s | 5 | 18° | 0.35 s | 20 px | no | 60 |

`WeaponState` maneja el cooldown, decide si dispara (`automatic` con botón mantenido, semiautomática con pulsación) y genera direcciones de proyectil repartidas uniformemente por la dispersión, sin RNG.

### D3. Balas con raycast y comprobación de terreno

`Bullet` (`Node2D`) avanza por `_physics_process`. Antes de mover:

1. Comprueba `terrain.is_solid_at_world(next_position)`; si es sólido, `terrain.explode(next_position, terrain_radius)` y termina.
2. Lanza un raycast contra la capa 2 (`collide_with_areas = true`) para objetivos; si impacta un `Area2D` con `take_damage`, aplica daño, emite `hit_target` y termina.
3. Si no impacta, se mueve y descuenta `lifetime`.

La comprobación de terreno usa la grilla pura, no la colisión física, para que sea determinista y barata. El raycast solo busca objetivos.

### D4. `BulletPool`

`BulletPool` (`Node2D`) mantiene listas de balas activas e inactivas, un máximo (64 por defecto), y reutiliza instancias. `spawn(...)` configura una bala y la activa; `finished` la devuelve al pool. El pool reemite `hit_confirmed(position, target)` para el hitstop.

### D5. Integración con el jugador

Se amplía `InputSource` con `is_shoot_pressed()` y `was_shoot_just_pressed()`. `LocalInputSource` usa `Input.is_action_pressed("shoot")` y `is_action_just_pressed("shoot")`; `ScriptedInputSource` añade variables para tests.

`Player` incorpora `WeaponState`, un `BulletPool` hijo y una referencia al terreno (por grupo `terrain` o inyectada). En `_physics_process`, tras moverse, llama `weapon_state.tick(delta)` y `try_fire(...)`; si dispara, genera las direcciones, spawnea balas y aplica retroceso `velocity -= aim * stats.recoil`. `set_weapon(stats)` cambia de arma y emite `weapon_changed`.

### D6. Objetivo de práctica y hitstop

`TrainingDummy` (`Area2D`, capa 2) usa `Health`, recibe daño y se oculta al morir. `HitStop` (`Node`) baja `Engine.time_scale` a `0.05` durante `duration` usando un `SceneTreeTimer` con `ignore_time_scale = true` y restaura 1.0. La escena de debug conecta `bullet_pool.hit_confirmed` a `HitStop.trigger(0.04)`.

### D7. Escena de debug

Se añade un `TrainingDummy` en `(300, 120)`, botones **Rifle** y **Shotgun** en una segunda fila del HUD, y se mantiene el botón **Explode**. El HUD muestra el arma activa. El jugador dispara con clic izquierdo o RT.

### D8. Tests

- `tests/unit/test_health.gd`: daño, letal, inválido, señales.
- `tests/unit/test_weapon_state.gd`: rifle automático, escopeta semiautomática, cooldown, dispersión y cambio de arma.
- `tests/integration/test_bullet_pool.gd`: reutilización, límite y expiración.
- `tests/integration/test_training_dummy.gd`: daño y muerte.
- `tests/integration/test_combat.gd`: disparo del jugador, impacto en dummy, impacto en terreno, retroceso e hitstop.
- `tests/integration/test_debug_session.gd`: dummy, botones de arma y HUD.

## Risks / Trade-offs

| Riesgo | Mitigación |
|---|---|
| El raycast no detecta `Area2D` | `collide_with_areas = true` y capa 2; test de impacto en dummy |
| La bala nace dentro del terreno | Comprobación de la celda siguiente; spawn a 12 px del jugador |
| El pool conserva balas procesándose | `set_physics_process(false)` al terminar y test de reutilización |
| El hitstop deja `time_scale` alterado | Timer con `ignore_time_scale`; test que verifica la restauración |
| Dispersión aleatoria hace tests frágiles | Dispersión determinista y uniforme, sin RNG |
| El retroceso molesta | Valor bajo en rifle y mayor en escopeta; ajuste en playtest |

## Migration Plan

No hay datos. Se amplían `InputSource`, `Player`, `player.tscn` y la escena de debug. Rollback: eliminar archivos nuevos y restaurar escenas.

## Open Questions

Ninguna que afecte al alcance. Munición y recarga quedan para un change posterior si el slice las necesita.
