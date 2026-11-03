# game-session Specification

## Purpose

Define el ciclo de vida de una partida arcade: estados, vidas, puntuación, pausa y reinicio, junto con su conexión a las acciones de entrada y a una escena de depuración observable.

## Requirements

### Requirement: Estado inicial de la sesión

Una sesión nueva DEBE (MUST) empezar en estado `READY`, con 3 vidas y 0 puntos, sin iniciar la partida automáticamente.

#### Scenario: Sesión recién creada

- **WHEN** se crea una sesión nueva
- **THEN** su estado es `READY`, tiene 3 vidas y 0 puntos

#### Scenario: Sin puntuación en espera

- **WHEN** se intenta sumar puntuación antes de iniciar la partida
- **THEN** la puntuación permanece en 0

### Requirement: Inicio de partida

La sesión DEBE (MUST) pasar de `READY` a `PLAYING` cuando se inicia, y DEBE ignorar el inicio si ya está en otro estado.

#### Scenario: Inicio desde READY

- **WHEN** la sesión está en `READY` y se inicia
- **THEN** el estado pasa a `PLAYING`

#### Scenario: Inicio repetido

- **WHEN** la sesión ya está en `PLAYING` y se vuelve a iniciar
- **THEN** el estado sigue en `PLAYING` sin reiniciar vidas ni puntuación

### Requirement: Pausa y reanudación

La sesión DEBE (MUST) pausarse solo desde `PLAYING` y reanudarse solo desde `PAUSED`; las transiciones inválidas no deben cambiar el estado.

#### Scenario: Pausar una partida activa

- **WHEN** la sesión está en `PLAYING` y se pausa
- **THEN** el estado pasa a `PAUSED`

#### Scenario: Reanudar una partida pausada

- **WHEN** la sesión está en `PAUSED` y se reanuda
- **THEN** el estado pasa a `PLAYING`

#### Scenario: Pausa ignorada fuera de PLAYING

- **WHEN** la sesión está en `READY` o `GAME_OVER` y se intenta pausar
- **THEN** el estado no cambia

#### Scenario: Alternar pausa

- **WHEN** la sesión está en `PLAYING` y se alterna la pausa dos veces
- **THEN** termina en `PLAYING`

### Requirement: Pérdida de vidas y fin de partida

La sesión DEBE (MUST) descontar una vida al perderla durante `PLAYING`, nunca por debajo de cero, y DEBE pasar a `GAME_OVER` cuando las vidas llegan a 0.

#### Scenario: Perder una vida

- **WHEN** la sesión está en `PLAYING` con vidas disponibles y pierde una vida
- **THEN** las vidas disminuyen en 1 y la partida continúa

#### Scenario: Última vida

- **WHEN** la sesión está en `PLAYING` con 1 vida y pierde una vida
- **THEN** las vidas quedan en 0 y el estado pasa a `GAME_OVER`

#### Scenario: Pérdida fuera de PLAYING

- **WHEN** la sesión está en `PAUSED` o `GAME_OVER` y pierde una vida
- **THEN** las vidas no cambian

#### Scenario: Sin vidas negativas

- **WHEN** la sesión está en `GAME_OVER` y se intenta perder otra vida
- **THEN** las vidas siguen en 0

### Requirement: Puntuación de la partida

La sesión DEBE (MUST) sumar puntos solo durante `PLAYING` y solo para cantidades positivas; la puntuación se conserva al terminar la partida.

#### Scenario: Sumar puntos en juego

- **WHEN** la sesión está en `PLAYING` y suma 100 puntos
- **THEN** la puntuación aumenta en 100

#### Scenario: Ignorar puntos inválidos

- **WHEN** la sesión está en `PLAYING` y suma 0 o una cantidad negativa
- **THEN** la puntuación no cambia

#### Scenario: Puntuación tras game over

- **WHEN** la sesión termina en `GAME_OVER`
- **THEN** conserva la puntuación acumulada para mostrarla

### Requirement: Reinicio de partida

La sesión DEBE (MUST) reiniciarse desde cualquier estado, dejando 3 vidas, 0 puntos y el estado `PLAYING`.

#### Scenario: Reinicio tras game over

- **WHEN** la sesión está en `GAME_OVER` y se reinicia
- **THEN** vuelve a `PLAYING` con 3 vidas y 0 puntos

#### Scenario: Reinicio durante la partida

- **WHEN** la sesión está en `PLAYING` o `PAUSED` y se reinicia
- **THEN** vuelve a `PLAYING` con 3 vidas y 0 puntos

### Requirement: Entrada de sesión

El controlador de sesión DEBE (MUST) traducir la acción `pause` en pausa/reanudación y la acción `restart` en reinicio, usando los bindings de teclado y gamepad existentes.

#### Scenario: Pausa desde teclado o gamepad

- **WHEN** el jugador pulsa la acción `pause`
- **THEN** la sesión alterna entre `PLAYING` y `PAUSED`

#### Scenario: Reinicio desde teclado o gamepad

- **WHEN** el jugador pulsa la acción `restart`
- **THEN** la sesión se reinicia con 3 vidas, 0 puntos y estado `PLAYING`

### Requirement: Escena de depuración de sesión

La escena principal DEBE (MUST) mostrar el estado, las vidas y la puntuación, y DEBE ofrecer acciones de depuración para perder una vida, sumar puntos y reiniciar.

#### Scenario: HUD refleja el estado

- **WHEN** la sesión cambia de estado, pierde una vida o suma puntos
- **THEN** las etiquetas de la escena muestran los valores actualizados

#### Scenario: Acciones de depuración

- **WHEN** el jugador usa los botones de perder vida, sumar puntos o reiniciar
- **THEN** la sesión aplica la acción correspondiente y el HUD se actualiza

#### Scenario: Arranque de la escena

- **WHEN** se carga la escena de depuración
- **THEN** la sesión está en `PLAYING` con 3 vidas y 0 puntos
