# player-controller Specification

## Purpose

Define el control del jugador: movimiento horizontal, salto con asistencia, apuntado 360°, entrada inyectable y cámara con look-ahead, junto con una escena jugable mínima.

## Requirements

### Requirement: Movimiento horizontal

El jugador DEBE (MUST) acelerar hacia la dirección de entrada hasta una velocidad máxima, desacelerar hasta detenerse sin entrada y respetar el límite de velocidad.

#### Scenario: Acelerar a la derecha

- **WHEN** el jugador está en el suelo y mantiene entrada hacia la derecha
- **THEN** su velocidad horizontal aumenta hasta la velocidad máxima

#### Scenario: Detenerse sin entrada

- **WHEN** el jugador se mueve y deja de recibir entrada horizontal
- **THEN** su velocidad horizontal disminuye hasta 0

#### Scenario: Límite de velocidad

- **WHEN** el jugador mantiene entrada en una dirección durante varios ticks
- **THEN** su velocidad horizontal no supera la velocidad máxima configurada

### Requirement: Gravedad y caída

El jugador DEBE (MUST) caer por gravedad cuando no está en el suelo y DEBE limitar su velocidad de caída a un máximo.

#### Scenario: Caída libre

- **WHEN** el jugador no está en el suelo
- **THEN** su velocidad vertical aumenta hacia abajo en cada tick

#### Scenario: Velocidad terminal

- **WHEN** el jugador cae durante suficientes ticks
- **THEN** su velocidad vertical no supera la velocidad máxima de caída

### Requirement: Salto variable

El jugador DEBE (MUST) saltar solo desde el suelo o dentro de la ventana de coyote time, y DEBE recortar la altura si se suelta el botón durante el ascenso.

#### Scenario: Salto desde el suelo

- **WHEN** el jugador está en el suelo y pulsa salto
- **THEN** su velocidad vertical se vuelve negativa

#### Scenario: Sin doble salto

- **WHEN** el jugador está en el aire y pulsa salto de nuevo
- **THEN** no se aplica un segundo impulso

#### Scenario: Salto recortado

- **WHEN** el jugador está ascendiendo y suelta salto
- **THEN** su velocidad vertical ascendente se reduce

### Requirement: Coyote time

El jugador DEBE (MUST) poder saltar durante una ventana breve después de abandonar una plataforma, y esa ventana DEBE expirar.

#### Scenario: Salto tardío tras salir del borde

- **WHEN** el jugador abandona el suelo y pulsa salto dentro de la ventana de coyote time
- **THEN** el salto se ejecuta

#### Scenario: Ventana expirada

- **WHEN** el jugador lleva más tiempo que la ventana de coyote time en el aire y pulsa salto
- **THEN** el salto no se ejecuta

### Requirement: Jump buffer

El jugador DEBE (MUST) recordar una pulsación de salto hecha poco antes de aterrizar y ejecutarla al tocar el suelo, con una ventana limitada.

#### Scenario: Salto memorizado antes de aterrizar

- **WHEN** el jugador pulsa salto en el aire poco antes de aterrizar
- **THEN** el salto se ejecuta al tocar el suelo

#### Scenario: Memoria expirada

- **WHEN** el jugador pulsa salto en el aire y aterriza después de la ventana de jump buffer
- **THEN** el salto no se ejecuta automáticamente

### Requirement: Apuntado 360°

El jugador DEBE (MUST) exponer una dirección de apuntado normalizada, calculada desde el stick derecho si se usa gamepad o desde la posición del puntero si se usa ratón.

#### Scenario: Apuntado con ratón

- **WHEN** el puntero está a la derecha y arriba del jugador
- **THEN** la dirección de apuntado es un vector normalizado hacia esa posición

#### Scenario: Apuntado con stick

- **WHEN** el stick derecho se mueve fuera de la zona muerta
- **THEN** la dirección de apuntado sigue al stick normalizado

#### Scenario: Sin entrada de apuntado

- **WHEN** no hay stick ni puntero válido
- **THEN** la dirección de apuntado por defecto es hacia la derecha

### Requirement: Entrada inyectable

El jugador DEBE (MUST) consumir la entrada a través de una abstracción inyectable y la lógica pura NO DEBE (MUST NOT) depender de `Input` global.

#### Scenario: Entrada guionizada en tests

- **WHEN** un test inyecta una fuente de entrada con movimiento y salto
- **THEN** el jugador responde a esos valores sin usar el teclado real

#### Scenario: Implementación local

- **WHEN** el jugador se ejecuta sin una fuente inyectada
- **THEN** usa la implementación local basada en las acciones del `InputMap`

### Requirement: Cámara con look-ahead

La cámara DEBE (MUST) seguir al jugador y desplazar su encuadre suavemente en la dirección de apuntado.

#### Scenario: Desplazamiento por apuntado

- **WHEN** el jugador apunta a la derecha
- **THEN** el objetivo de la cámara se desplaza a la derecha

#### Scenario: Suavizado

- **WHEN** cambia la dirección de apuntado
- **THEN** la cámara se aproxima al nuevo objetivo de forma gradual, sin saltos instantáneos

### Requirement: Playground de depuración

La escena de depuración DEBE (MUST) incluir al jugador, un suelo y una plataforma, manteniendo el HUD y los controles de sesión.

#### Scenario: Jugador sobre el suelo

- **WHEN** se carga la escena de depuración y pasan suficientes frames de física
- **THEN** el jugador está apoyado sobre el suelo

#### Scenario: HUD conservado

- **WHEN** se carga la escena de depuración
- **THEN** el estado, las vidas, la puntuación y los botones de sesión siguen disponibles

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
