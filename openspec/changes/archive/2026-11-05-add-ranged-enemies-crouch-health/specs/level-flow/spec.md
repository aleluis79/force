# Spec Delta

## MODIFIED Requirements

### Requirement: Muerte y reaparición

El jugador DEBE (MUST) morir solo cuando su salud llegue a 0, perder una vida y reaparecer con salud completa en el checkpoint si le quedan vidas.

#### Scenario: Muerte con vidas

- **WHEN** la salud del jugador llega a 0 y tiene vidas restantes
- **THEN** pierde una vida y reaparece en el checkpoint con salud completa e invulnerabilidad breve

#### Scenario: Última vida

- **WHEN** la salud del jugador llega a 0 sin vidas restantes
- **THEN** la sesión pasa a `GAME_OVER`

#### Scenario: Caída al vacío

- **WHEN** el jugador cae fuera del nivel
- **THEN** muere y se aplica el mismo flujo de vidas

## ADDED Requirements

### Requirement: Barra de salud en el HUD

El HUD del nivel DEBE (MUST) mostrar una barra con la salud actual y máxima del jugador, actualizada al recibir daño y al reaparecer.

#### Scenario: Actualización al recibir daño

- **WHEN** el jugador recibe daño
- **THEN** la barra de salud refleja el nuevo valor actual

#### Scenario: Reaparición con salud completa

- **WHEN** el jugador reaparece tras perder una vida
- **THEN** la barra de salud vuelve a mostrarse llena
