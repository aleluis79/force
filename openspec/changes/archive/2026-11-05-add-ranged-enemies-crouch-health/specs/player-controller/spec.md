# Spec Delta

## ADDED Requirements

### Requirement: Agacharse

El jugador DEBE (MUST) poder agacharse mediante una acción de entrada dedicada, reduciendo su altura de colisión mientras mantiene la acción y estando en el suelo.

#### Scenario: Reducir el hitbox

- **WHEN** el jugador está en el suelo y mantiene la acción de agacharse
- **THEN** su altura de colisión disminuye y los disparos dirigidos a la altura del torso pasan por encima

#### Scenario: Volver a estar de pie

- **WHEN** el jugador suelta la acción de agacharse
- **THEN** recupera su altura de colisión normal

#### Scenario: Pose legible

- **WHEN** el jugador se agacha
- **THEN** usa una pose dedicada que mantiene la cabeza sin deformar y conserva los pies apoyados

#### Scenario: Entrada de agacharse

- **WHEN** el jugador usa teclado o gamepad
- **THEN** existe una acción de entrada para agacharse con ambos tipos de dispositivo

### Requirement: Movimiento agachado

El jugador DEBE (MUST) moverse más lentamente mientras está agachado y en el suelo.

#### Scenario: Velocidad reducida

- **WHEN** el jugador se mueve horizontalmente mientras está agachado
- **THEN** su velocidad horizontal es menor que la velocidad máxima de pie
