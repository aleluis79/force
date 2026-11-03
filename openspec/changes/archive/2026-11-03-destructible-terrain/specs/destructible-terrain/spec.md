# Spec Delta: destructible-terrain

## Purpose

Define el terreno destructible del juego: una grilla de celdas sólidas que puede rellenarse, destruirse por explosiones circulares, renderizarse con tiles y colisionar con el jugador.

## ADDED Requirements

### Requirement: Grilla de celdas

El terreno DEBE (MUST) modelarse como una grilla bidimensional de celdas de 8 px, cada una sólida o vacía, con límites definidos.

#### Scenario: Celda dentro de los límites

- **WHEN** se consulta una celda dentro de la grilla
- **THEN** se obtiene su estado sólido o vacío

#### Scenario: Celda fuera de los límites

- **WHEN** se consulta una celda fuera de la grilla
- **THEN** se considera vacía y no se modifica el terreno

### Requirement: Relleno y conteo de celdas

La grilla DEBE (MUST) permitir rellenar rectángulos de celdas y contar cuántas están sólidas.

#### Scenario: Rellenar un rectángulo

- **WHEN** se rellena un rectángulo dentro de los límites
- **THEN** todas sus celdas quedan sólidas y el conteo aumenta en la cantidad correspondiente

#### Scenario: Relleno parcialmente fuera de límites

- **WHEN** se rellena un rectángulo que se sale de la grilla
- **THEN** solo se modifican las celdas dentro de los límites

### Requirement: Destrucción circular

Una explosión DEBE (MUST) destruir las celdas sólidas cuyo centro esté dentro del radio, devolver solo las celdas efectivamente destruidas y no repetir celdas.

#### Scenario: Explosión en terreno sólido

- **WHEN** se destruye un círculo sobre celdas sólidas
- **THEN** esas celdas pasan a vacías y se devuelven como destruidas

#### Scenario: Explosión sobre celdas vacías

- **WHEN** se destruye un círculo donde ya no hay celdas sólidas
- **THEN** no se devuelve ninguna celda y el conteo no cambia

#### Scenario: Explosión en el borde

- **WHEN** el círculo de destrucción se sale de los límites
- **THEN** la operación no falla y solo afecta celdas dentro de la grilla

#### Scenario: Explosión repetida

- **WHEN** se ejecuta dos veces la misma explosión
- **THEN** la segunda no devuelve celdas y el terreno queda igual que tras la primera

### Requirement: Representación por tiles

El terreno DEBE (MUST) renderizar cada celda sólida como un tile de 8×8 y DEBE eliminar el tile de cada celda destruida.

#### Scenario: Render inicial

- **WHEN** el terreno se inicializa con celdas sólidas
- **THEN** cada celda sólida tiene un tile visible

#### Scenario: Tile eliminado tras la explosión

- **WHEN** una explosión destruye celdas
- **THEN** los tiles de esas celdas desaparecen y no quedan tiles obsoletos

### Requirement: Colisión del terreno

Las celdas sólidas DEBEN (MUST) tener colisión y las celdas destruidas DEBEN (MUST NOT) seguir colisionando.

#### Scenario: Jugador apoyado sobre el terreno

- **WHEN** el jugador cae sobre una zona sólida
- **THEN** queda apoyado y no atraviesa el terreno

#### Scenario: Jugador sobre un hueco

- **WHEN** se destruye el terreno bajo el jugador
- **THEN** la colisión desaparece en esas celdas y el jugador puede caer

### Requirement: Señal de destrucción

Cada explosión DEBE (MUST) emitir una señal con las celdas destruidas y la posición mundial de la explosión para que la presentación genere debris.

#### Scenario: Señal con celdas afectadas

- **WHEN** una explosión destruye al menos una celda
- **THEN** se emite una señal con la lista de celdas y la posición de la explosión

#### Scenario: Señal sin celdas

- **WHEN** una explosión no destruye ninguna celda
- **THEN** no se emite una señal de destrucción

### Requirement: Terreno en la escena de depuración

La escena de depuración DEBE (MUST) usar terreno destructible como suelo y plataforma, y DEBE ofrecer una acción para detonar una explosión de prueba.

#### Scenario: Suelo destructible

- **WHEN** se carga la escena de depuración
- **THEN** el jugador aterriza sobre el terreno destructible

#### Scenario: Botón de explosión

- **WHEN** el jugador pulsa la acción de explosión de depuración
- **THEN** se destruye terreno cerca del jugador y el HUD sigue funcionando
