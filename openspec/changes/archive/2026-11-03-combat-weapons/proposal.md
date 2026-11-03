# Proposal: combat-weapons

## Why

El terreno ya se destruye, pero el jugador no puede disparar. Sin combate no hay forma de enfrentarse a enemigos ni de convertir la destrucción en una mecánica de juego.

## What Changes

- Añadir salud y daño puros reutilizables por el jugador, enemigos y objetivos.
- Definir rifle (automático) y escopeta (semiautomática, varios perdigones) con cadencia, dispersión, daño, velocidad y retroceso.
- Implementar disparo desde el jugador usando el apuntado 360° y la acción `shoot`.
- Añadir balas con pooling, tiempo de vida, límite de activas e impacto contra objetivos y terreno.
- Crear un objetivo de entrenamiento con salud para validar el daño.
- Añadir hitstop breve al confirmar impacto.
- Exponer botones de depuración para cambiar de arma y un objetivo de práctica en la escena.

**Fuera de alcance:** enemigos con IA, rescates, niveles, victoria/derrota, arte final y audio.

## Capabilities

### New Capabilities

- `combat`: salud, armas, disparo, balas, pooling, impacto en objetivos y terreno, retroceso e hitstop.

### Modified Capabilities

Ninguna. `player-controller` conserva su contrato; el `InputSource` se amplía con métodos de disparo sin cambiar el comportamiento existente.

## Impact

- **Nuevo:** `src/core/health.gd`, `src/core/weapon_stats.gd`, `src/core/weapon_state.gd`, `src/entities/bullet.gd`, `src/entities/bullet_pool.gd`, `src/entities/training_dummy.gd`, `src/presentation/hit_stop.gd`, `scenes/training_dummy.tscn`, tests.
- **Modificado:** `src/core/input_source.gd`, `src/presentation/local_input_source.gd`, `src/entities/player.gd`, `scenes/player.tscn`, `scenes/debug_session.tscn`, `src/presentation/debug_session.gd`, tests y README.
- **Riesgo:** el raycast de balas contra `Area2D` y el ciclo del pool; se mitiga con tests de integración y un objetivo de práctica.
