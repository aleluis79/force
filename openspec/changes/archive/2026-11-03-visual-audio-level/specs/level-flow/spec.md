# Spec Delta: level-flow

## MODIFIED Requirements

### Requirement: Nivel jugable

El nivel DEBE (MUST) tener 1920 px de ancho, terreno destructible con plataformas, jugador, al menos 10 enemigos, al menos 4 prisioneros y una salida.

#### Scenario: Carga del nivel

- **WHEN** se carga el nivel
- **THEN** el jugador aparece sobre el terreno y existen al menos 10 enemigos, 4 prisioneros y una salida

#### Scenario: Cámara del nivel

- **WHEN** el jugador avanza hacia la derecha
- **THEN** la cámara lo sigue dentro de los límites del nivel
