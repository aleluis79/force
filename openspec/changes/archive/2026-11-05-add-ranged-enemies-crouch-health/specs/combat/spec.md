# Spec Delta

## ADDED Requirements

### Requirement: Salud del jugador

El jugador DEBE (MUST) tener una reserva de salud con un máximo y un valor actual, recibir daño positivo y morir solo cuando su salud llegue a 0.

#### Scenario: Recibir un disparo

- **WHEN** el jugador recibe el daño de un proyectil enemigo
- **THEN** su salud actual disminuye sin llegar a valores negativos

#### Scenario: Agotar la salud

- **WHEN** la salud del jugador llega a 0
- **THEN** el jugador emite su muerte una sola vez y deja de ser dañable

### Requirement: Invulnerabilidad tras recibir daño

El jugador DEBE (MUST) ignorar daño adicional durante una ventana breve después de recibir un impacto o reaparecer.

#### Scenario: Impacto repetido

- **WHEN** el jugador recibe dos impactos dentro de la ventana de invulnerabilidad
- **THEN** solo se descuenta la salud del primer impacto

#### Scenario: Reaparición protegida

- **WHEN** el jugador reaparece después de perder una vida
- **THEN** es invulnerable durante un breve periodo inicial

### Requirement: Proyectiles enemigos destructibles

Las balas del jugador DEBEN (MUST) poder destruir los proyectiles enemigos antes de que alcancen al jugador.

#### Scenario: Interceptar un proyectil

- **WHEN** una bala del jugador impacta en un proyectil enemigo
- **THEN** el proyectil enemigo desaparece y no daña al jugador

#### Scenario: Proyectil que llega al jugador

- **WHEN** un proyectil enemigo impacta en el jugador
- **THEN** le aplica daño y el proyectil desaparece

#### Scenario: Proyectil contra terreno

- **WHEN** un proyectil enemigo entra en una celda sólida
- **THEN** desaparece sin destruir el terreno
