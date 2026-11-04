# Spec Delta: combat

## ADDED Requirements

### Requirement: Punto de salida de las balas

Las balas DEBEN (MUST) originarse en la boca del arma, por encima del centro del jugador y desplazadas en la dirección de apuntado.

#### Scenario: Disparo hacia la derecha

- **WHEN** el jugador apunta a la derecha y dispara
- **THEN** la bala nace por encima del centro y a la derecha del jugador

#### Scenario: Disparo hacia la izquierda

- **WHEN** el jugador apunta a la izquierda y dispara
- **THEN** la bala nace por encima del centro y a la izquierda del jugador

#### Scenario: Disparo hacia arriba

- **WHEN** el jugador apunta hacia arriba y dispara
- **THEN** la bala nace claramente por encima del jugador
