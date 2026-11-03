# Spec Delta: game-session

## ADDED Requirements

### Requirement: Victoria de nivel

La sesión DEBE (MUST) poder pasar de `PLAYING` a `VICTORY` al completar el nivel e ignorar la victoria en otros estados.

#### Scenario: Completar el nivel

- **WHEN** la sesión está en `PLAYING` y el jugador alcanza la salida
- **THEN** el estado pasa a `VICTORY`

#### Scenario: Victoria fuera de juego

- **WHEN** la sesión está en `PAUSED` o `GAME_OVER` y se intenta ganar
- **THEN** el estado no cambia

### Requirement: Vida extra

La sesión DEBE (MUST) permitir sumar una vida extra y notificar el cambio.

#### Scenario: Rescate con vida extra

- **WHEN** la sesión recibe una vida extra
- **THEN** las vidas aumentan en 1 y se emite la señal de vidas

## MODIFIED Requirements

### Requirement: Escena de depuración de sesión

La escena de depuración DEBE (MUST) mostrar el estado, las vidas y la puntuación, y DEBE ofrecer acciones de depuración para perder una vida, sumar puntos y reiniciar.

#### Scenario: HUD refleja el estado

- **WHEN** la sesión cambia de estado, pierde una vida o suma puntos
- **THEN** las etiquetas de la escena muestran los valores actualizados

#### Scenario: Acciones de depuración

- **WHEN** el jugador usa los botones de perder vida, sumar puntos o reiniciar
- **THEN** la sesión aplica la acción correspondiente y el HUD se actualiza

#### Scenario: Arranque de la escena

- **WHEN** se carga la escena de depuración
- **THEN** la sesión está en `PLAYING` con 3 vidas y 0 puntos
