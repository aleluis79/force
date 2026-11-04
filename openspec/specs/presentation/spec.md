# presentation Specification

## Purpose

Define la identidad visual del juego: sprites pixel art, terreno con variantes, fondo parallax, fuente pixel, HUD legible y feedback de cámara.

## Requirements

### Requirement: Sprites pixel art

El jugador, los enemigos, el POW, el dummy, la bala y la salida DEBEN (MUST) usar texturas pixel art con filtro nearest y tamaños coherentes con la resolución interna.

#### Scenario: Jugador con sprite

- **WHEN** se carga el jugador
- **THEN** muestra un sprite pixel art en lugar de una forma geométrica

#### Scenario: Enemigos y objetos con sprite

- **WHEN** se cargan enemigos, POW, dummy, bala o salida
- **THEN** cada uno tiene una textura no nula y se renderiza con nearest

### Requirement: Terreno con superficie y tierra

El terreno DEBE (MUST) distinguir visualmente la superficie (hierba) de la tierra y DEBE actualizar la variante al destruir celdas.

#### Scenario: Superficie de hierba

- **WHEN** una celda sólida no tiene otra celda sólida encima
- **THEN** se renderiza con el tile de hierba

#### Scenario: Tierra bajo la superficie

- **WHEN** una celda sólida tiene otra celda sólida encima
- **THEN** se renderiza con el tile de tierra

#### Scenario: Actualización tras destrucción

- **WHEN** se destruye la celda de superficie
- **THEN** la celda inferior pasa a renderizarse como hierba

### Requirement: Fondo parallax

El nivel DEBE (MUST) tener un fondo con al menos dos capas de parallax además del cielo.

#### Scenario: Capas de fondo

- **WHEN** la cámara se mueve horizontalmente
- **THEN** las capas de montañas y selva se desplazan a distinta velocidad

### Requirement: Fuente y tema pixel

El HUD DEBE (MUST) usar una fuente pixel y un tema global legible a la resolución interna.

#### Scenario: Tema cargado

- **WHEN** se inicia el proyecto
- **THEN** el tema global usa la fuente pixel y un tamaño legible

### Requirement: Screenshake

La cámara DEBE (MUST) sacudirse brevemente al confirmar impactos y explosiones.

#### Scenario: Impacto

- **WHEN** una bala impacta en un objetivo
- **THEN** la cámara recibe una sacudida breve

#### Scenario: Explosión

- **WHEN** se destruye terreno
- **THEN** la cámara recibe una sacudida proporcional

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
