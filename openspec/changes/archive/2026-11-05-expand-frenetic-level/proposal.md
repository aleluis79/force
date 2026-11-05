# Proposal

## Why

El nivel actual dura 1920 px, tiene solo 8 plataformas y 10 enemigos. La progresión se agota rápido y el combate no alcanza la sensación frenética de un run-and-gun. Además, varias plataformas no tienen una ruta de salto verificada, así que pueden quedar decorativas o inalcanzables.

## What Changes

- Duplicar la longitud del nivel a 3840 px con una ruta continua de plataformas.
- Añadir al menos 25 plataformas nuevas, con separaciones y alturas compatibles con el salto del jugador.
- Aumentar la densidad a 30+ enemigos y 8 prisioneros distribuidos por todo el nivel.
- Mover la salida al final del nivel extendido.
- Aumentar la presión de disparo enemiga con más soldados y una cadencia más corta.
- Añadir verificaciones automáticas de alcanzabilidad, solidez y espacio libre de todas las plataformas.
- Mantener el terreno destructible, el sistema de vidas y la barra de salud.

**Fuera de alcance:** nuevos tipos de enemigo, jefes finales, checkpoints múltiples, música nueva, cambios al sistema de puntuación y rediseño completo del arte de fondo.

## Capabilities

### New Capabilities

<!-- Ninguna. -->

### Modified Capabilities

- `level-flow`: nivel de 3840 px, densidad de enemigos/POWs, salida al final y plataformas verificables.

## Impact

- Datos de nivel en `src/level/level.gd` y `scenes/level_01.tscn`.
- Spawns de enemigos y POWs, posición de salida y límites de cámara.
- Cadencia de disparo del soldado.
- Tests de nivel, geometría de plataformas y combate.
