# Spec Delta

## Purpose

Define la pantalla inicial del juego, sus opciones básicas y la navegación hacia la partida, los controles y la salida.

## ADDED Requirements

### Requirement: Menú inicial

El juego DEBE (MUST) arrancar en una escena de menú inicial con las opciones Jugar, Opciones, Controles y Salir.

#### Scenario: Arranque del menú

- **WHEN** se inicia el juego
- **THEN** aparece el menú inicial en lugar del nivel

#### Scenario: Jugar

- **WHEN** el jugador activa Jugar
- **THEN** se carga el nivel jugable

#### Scenario: Salir

- **WHEN** el jugador activa Salir
- **THEN** el juego se cierra

### Requirement: Opciones del menú

El menú DEBE (MUST) ofrecer un panel de opciones con pantalla completa y volumen maestro, y DEBE (MUST) permitir volver al menú principal.

#### Scenario: Alternar pantalla completa

- **WHEN** el jugador activa la opción de pantalla completa
- **THEN** la ventana alterna entre modo ventana y pantalla completa y la etiqueta refleja el estado

#### Scenario: Cambiar volumen

- **WHEN** el jugador activa la opción de volumen
- **THEN** el volumen maestro cambia a un paso distinto y la etiqueta muestra el porcentaje

#### Scenario: Volver desde opciones

- **WHEN** el jugador activa Volver
- **THEN** regresa al menú principal

### Requirement: Panel de controles

El menú DEBE (MUST) mostrar un panel con los controles principales y permitir volver al menú.

#### Scenario: Consultar controles

- **WHEN** el jugador activa Controles
- **THEN** se muestra el resumen de movimiento, salto, agacharse, disparo y pausa

### Requirement: Navegación del menú

El menú DEBE (MUST) poder operarse con ratón, teclado y gamepad, con un foco inicial visible y `Esc` para volver desde un panel.

#### Scenario: Foco inicial

- **WHEN** se abre el menú
- **THEN** el botón Jugar tiene el foco

#### Scenario: Volver con Esc

- **WHEN** el jugador está en Opciones o Controles y pulsa `Esc`
- **THEN** vuelve al menú principal
