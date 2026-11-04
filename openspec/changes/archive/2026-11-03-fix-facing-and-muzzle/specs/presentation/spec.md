# Spec Delta: presentation

## ADDED Requirements

### Requirement: Orientación de sprites

El jugador DEBE (MUST) mirar hacia su dirección de movimiento mientras se desplaza y hacia la dirección de apuntado cuando está quieto. Los enemigos DEBEN (MUST) mirar hacia su dirección de persecución.

#### Scenario: Jugador moviéndose a la izquierda

- **WHEN** el jugador se mueve a la izquierda
- **THEN** su sprite se voltea hacia la izquierda

#### Scenario: Jugador quieto apuntando a la izquierda

- **WHEN** el jugador está quieto y apunta a la izquierda
- **THEN** su sprite se voltea hacia la izquierda

#### Scenario: Enemigo persiguiendo a la izquierda

- **WHEN** el soldado enemigo persigue a un jugador situado a su izquierda
- **THEN** su sprite se voltea hacia la izquierda

#### Scenario: Enemigo bloqueado

- **WHEN** el soldado intenta avanzar hacia la izquierda pero una pared lo bloquea
- **THEN** su sprite sigue mirando a la izquierda
