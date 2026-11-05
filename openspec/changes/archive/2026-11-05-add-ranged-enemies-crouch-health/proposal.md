# Proposal

## Why

El combate actual es de una sola dirección: los enemigos solo dañan por contacto y el jugador muere de un golpe. Eso elimina la lectura de proyectiles, la gestión de riesgo y la posibilidad de esquivar. Para que el vertical slice se sienta como un run-and-gun, los enemigos deben disparar, el jugador debe poder agacharse y destruir proyectiles, y su supervivencia debe comunicarse con una barra de salud.

## What Changes

- Los soldados enemigos disparan proyectiles dirigidos al torso del jugador cuando está dentro de su rango, con cadencia limitada.
- Los proyectiles enemigos viajan en línea recta, dañan al jugador y desaparecen al impactar en terreno o jugador.
- El jugador puede agacharse para reducir su hitbox y esquivar disparos altos.
- Las balas del jugador destruyen los proyectiles enemigos antes de que impacten.
- El jugador pasa de muerte de un golpe a una reserva de salud con invulnerabilidad breve tras recibir daño.
- El HUD muestra una barra de salud; al llegar a 0 se pierde una vida y se reaparece con salud completa.
- Se conserva el sistema de vidas y checkpoints existente.

**Fuera de alcance:** nuevos tipos de enemigo, armas enemigas múltiples, cobertura dinámica, animaciones nuevas de agacharse dibujadas a mano, barra de salud para enemigos y rebalanceo completo de dificultad.

## Capabilities

### New Capabilities

<!-- Ninguna. -->

### Modified Capabilities

- `combat`: salud del jugador, proyectiles enemigos destructibles y daño recibido con invulnerabilidad breve.
- `enemies`: soldados con ataque a distancia y cadencia; el kamikaze mantiene su ataque por contacto.
- `player-controller`: acción de agacharse, reducción de hitbox y movimiento agachado.
- `level-flow`: barra de salud en el HUD, muerte al agotar salud y reaparición con salud completa.

## Impact

- Entrada: nueva acción `crouch` en `InputMap` y en `InputSource`.
- Entidades: `Player`, `Grunt`, nuevo proyectil enemigo y pool/origen de disparo.
- Presentación: HUD del nivel, feedback de daño y sonidos de impacto/disparo.
- Specs y tests: escenarios de combate, enemigos, controlador y flujo de nivel.
- Sin cambios de compatibilidad para el terreno destructible ni para el sistema de vidas.
