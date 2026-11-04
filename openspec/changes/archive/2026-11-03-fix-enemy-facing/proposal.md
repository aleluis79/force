# Proposal: fix-enemy-facing

## Why

Los sprites humanos del pack miran a la izquierda por defecto, pero el código asumía que miraban a la derecha. Por eso los soldados enemigos giran al revés y miran en dirección contraria al jugador. El misil del kamikaze también apunta a la izquierda, así que vuela visualmente hacia atrás.

## What Changes

- Invertir el `flip_h` del soldado enemigo para que mire hacia el jugador.
- Voltear el sprite del kamikaze para que su morro apunte a la derecha y la rotación coincida con la dirección de vuelo.
- Añadir tests de orientación en ambos sentidos.

**Fuera de alcance:** cambios de comportamiento, arte nuevo o balance.

## Capabilities

### New Capabilities

Ninguna.

### Modified Capabilities

Ninguna. El comportamiento especificado no cambia; se corrige la implementación para cumplir la spec existente de orientación de sprites.

## Impact

- **Modificado:** `src/entities/grunt.gd`, `scenes/kamikaze.tscn`, `tests/integration/test_enemies.gd`.
- **Riesgo:** bajo; se cubre con tests de orientación a izquierda y derecha.
