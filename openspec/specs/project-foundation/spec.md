# project-foundation Specification

## Purpose

Define la base verificable del proyecto: arranque sin errores, suite de pruebas headless reproducible, presentación pixel-perfect, acciones de entrada estables y separación entre lógica pura y nodos.

## Requirements

### Requirement: Arranque headless sin errores

El proyecto DEBE (MUST) iniciar en modo headless sin errores de script ni dependencias faltantes, y DEBE cerrar con código de salida 0.

#### Scenario: Arranque limpio

- **WHEN** se inicia el proyecto en modo headless con cierre inmediato
- **THEN** el proceso termina con código 0 y sin errores de script en la salida

#### Scenario: Escena principal estable

- **WHEN** se carga la escena principal en modo headless
- **THEN** la escena se instancia y permanece estable durante al menos 60 frames de física

### Requirement: Suite de pruebas reproducible

El proyecto DEBE (MUST) ofrecer un único comando local que ejecute todas las pruebas automatizadas en modo headless y devuelva un código de salida distinto de cero si alguna prueba falla.

#### Scenario: Suite en verde

- **WHEN** se ejecuta el comando de pruebas y todas las pruebas pasan
- **THEN** el comando termina con código 0 y muestra el resumen de pruebas ejecutadas

#### Scenario: Fallo detectado

- **WHEN** una prueba falla
- **THEN** el comando termina con código distinto de cero y muestra el nombre de la prueba fallida

### Requirement: Validación SDD en la puerta de calidad

El comando de pruebas DEBE (MUST) validar los artifacts de OpenSpec en modo estricto y fallar si existe un change o spec inválido.

#### Scenario: Artifacts válidos

- **WHEN** todos los changes y specs cumplen el esquema
- **THEN** la validación termina con código 0

#### Scenario: Artifact inválido

- **WHEN** un change o spec incumple el esquema
- **THEN** la validación termina con código distinto de cero y señala el artifact afectado

### Requirement: Presentación pixel-perfect

La vista DEBE (MUST) renderizarse a 480×270 píxeles internos, escalarse a la ventana en múltiplos enteros y usar muestreo nearest, sin filtrado ni píxeles parciales.

#### Scenario: Ventana 1440×810

- **WHEN** la ventana mide 1440×810
- **THEN** cada píxel interno ocupa exactamente una cuadrícula de 3×3 píxeles de pantalla

#### Scenario: Ventana no múltipla

- **WHEN** la ventana no es un múltiplo entero de 480×270
- **THEN** la imagen conserva la proporción y se aplican barras negras, sin deformación

#### Scenario: Movimiento sin píxeles parciales

- **WHEN** un sprite se mueve por la escena
- **THEN** su posición renderizada se alinea a la cuadrícula de píxeles internos

### Requirement: Acciones de entrada estables

El proyecto DEBE (MUST) definir al arrancar las acciones `move_left`, `move_right`, `aim_left`, `aim_right`, `aim_up`, `aim_down`, `jump`, `shoot`, `special`, `pause` y `restart`, con bindings de teclado o ratón y de gamepad según el dispositivo.

#### Scenario: Acciones disponibles

- **WHEN** el proyecto arranca
- **THEN** las once acciones existen en el mapa de entrada

#### Scenario: Cobertura de teclado y ratón

- **WHEN** se inspeccionan los bindings de movimiento, salto, disparo, especial, pausa y reinicio
- **THEN** cada una tiene al menos un binding de teclado o ratón

#### Scenario: Cobertura de gamepad

- **WHEN** se inspeccionan los bindings de las acciones de juego
- **THEN** cada una, incluidas las de apuntado, tiene al menos un binding de gamepad

#### Scenario: Pausa y reinicio accesibles

- **WHEN** el jugador usa teclado o gamepad
- **THEN** puede activar pausa y reinicio sin depender del ratón

### Requirement: Lógica pura aislada de nodos

La lógica de juego en `src/core` DEBE (MUST) poder instanciarse y probarse sin árbol de escena y NO DEBE (MUST NOT) depender de `Input` global, autoloads, reloj de pared ni RNG global.

#### Scenario: Prueba sin árbol

- **WHEN** una prueba unitaria instancia una utilidad de lógica pura
- **THEN** la prueba se ejecuta sin añadir nodos al árbol de escena

#### Scenario: Dependencia prohibida

- **WHEN** el código de lógica pura referencia `Input`, `get_tree`, `Time` o `randf`
- **THEN** la verificación estática falla e indica el archivo y la línea

### Requirement: Decisiones técnicas registradas

El proyecto DEBE (MUST) documentar en ADRs la versión del motor, la estrategia de pruebas, la resolución interna y la separación entre lógica y nodos, incluyendo fecha y estado de cada decisión.

#### Scenario: ADR disponible

- **WHEN** un desarrollador busca las decisiones de base del proyecto
- **THEN** encuentra al menos un ADR con contexto, decisión, alternativas y consecuencias
