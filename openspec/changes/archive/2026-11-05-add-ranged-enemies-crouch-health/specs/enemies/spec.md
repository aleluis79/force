# Spec Delta

## ADDED Requirements

### Requirement: Soldado con ataque a distancia

El soldado enemigo DEBE (MUST) disparar proyectiles hacia el torso del jugador cuando esté dentro de su rango de tiro y su cadencia lo permita.

#### Scenario: Disparo dentro del rango

- **WHEN** el jugador está dentro del rango de tiro del soldado y este tiene el arma lista
- **THEN** el soldado genera un proyectil dirigido a la altura del torso del jugador

#### Scenario: Cadencia limitada

- **WHEN** el soldado acaba de disparar y el jugador sigue en rango
- **THEN** no dispara otro proyectil hasta que pase su intervalo de disparo

#### Scenario: Fuera de rango

- **WHEN** el jugador está fuera del rango de tiro del soldado
- **THEN** el soldado no genera proyectiles

#### Scenario: Soldado muerto

- **WHEN** el soldado muere
- **THEN** deja de disparar proyectiles
