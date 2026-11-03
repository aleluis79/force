# Spec Delta: rescue-system

## Purpose

Define prisioneros rescatables que recompensan al jugador con una vida, puntuación y un nuevo checkpoint.

## ADDED Requirements

### Requirement: Rescate por contacto

Un prisionero DEBE (MUST) rescatarse cuando el jugador lo toca y DEBE desaparecer una sola vez.

#### Scenario: Rescate

- **WHEN** el jugador toca a un prisionero
- **THEN** el prisionero se rescata y desaparece

#### Scenario: Sin doble rescate

- **WHEN** el prisionero ya fue rescatado
- **THEN** no vuelve a otorgar recompensas

### Requirement: Recompensa del rescate

Cada rescate DEBE (MUST) dar una vida extra, sumar 500 puntos y actualizar el checkpoint al lugar del prisionero.

#### Scenario: Vida y puntos

- **WHEN** el jugador rescata a un prisionero
- **THEN** sus vidas aumentan en 1 y su puntuación en 500

#### Scenario: Nuevo checkpoint

- **WHEN** el jugador rescata a un prisionero y muere después
- **THEN** reaparece en la posición del prisionero rescatado
