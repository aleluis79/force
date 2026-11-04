# Proposal: fix-facing-and-muzzle

## Why

El jugador y los enemigos no giran el sprite cuando cambian de dirección, y las balas aparecen demasiado bajas porque nacen en el centro del cuerpo en lugar de la boca del arma. Ambos defectos rompen la legibilidad del combate.

## What Changes

- El jugador mira hacia la dirección de movimiento mientras se desplaza y hacia el apuntado cuando está quieto.
- El soldado enemigo mira hacia la dirección en la que intenta perseguir, aunque una pared lo bloquee.
- Las balas nacen en un punto de la boca del arma, elevado respecto al centro y desplazado en la dirección de apuntado.
- Tests de orientación y de origen del proyectil.

**Fuera de alcance:** nuevas animaciones, armas o cambios de equilibrio.

## Capabilities

### New Capabilities

Ninguna.

### Modified Capabilities

- `presentation`: se añade la orientación correcta de los sprites.
- `combat`: se añade el punto de salida de las balas desde el arma.

## Impact

- **Modificado:** `src/entities/player.gd`, `src/entities/grunt.gd`, `src/entities/player.gd` (`_fire`), tests de jugador/enemigos/combate.
- **Riesgo:** el offset del arma puede necesitar ajuste fino; se centraliza en constantes y se valida con tests.
