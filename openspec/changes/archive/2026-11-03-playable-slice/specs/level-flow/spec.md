# Spec Delta: level-flow

## Purpose

Define el nivel jugable, la muerte y reaparición del jugador, la salida, la victoria, el game over, la pausa, el reinicio y el HUD.

## ADDED Requirements

### Requirement: Nivel jugable

El nivel DEBE (MUST) tener 960 px de ancho, terreno destructible con plataformas, jugador, enemigos, prisioneros y una salida.

#### Scenario: Carga del nivel

- **WHEN** se carga el nivel
- **THEN** el jugador aparece sobre el terreno y existen enemigos, prisioneros y salida

#### Scenario: Cámara del nivel

- **WHEN** el jugador avanza hacia la derecha
- **THEN** la cámara lo sigue dentro de los límites del nivel

### Requirement: Muerte y reaparición

El jugador DEBE (MUST) morir al recibir daño, perder una vida y reaparecer en el checkpoint si le quedan vidas.

#### Scenario: Muerte con vidas

- **WHEN** el jugador recibe daño y tiene vidas restantes
- **THEN** pierde una vida y reaparece en el checkpoint con invulnerabilidad breve

#### Scenario: Última vida

- **WHEN** el jugador recibe daño sin vidas restantes
- **THEN** la sesión pasa a `GAME_OVER`

#### Scenario: Caída al vacío

- **WHEN** el jugador cae fuera del nivel
- **THEN** muere y se aplica el mismo flujo de vidas

### Requirement: Salida y victoria

El nivel DEBE (MUST) tener una salida que, al alcanzarla, complete la partida.

#### Scenario: Alcanzar la salida

- **WHEN** el jugador toca la salida durante `PLAYING`
- **THEN** la sesión pasa a `VICTORY`

### Requirement: Pausa, game over y reinicio

La partida DEBE (MUST) pausarse con la acción `pause`, detenerse en game over/victoria y reiniciarse con `restart`.

#### Scenario: Pausa

- **WHEN** el jugador pulsa `pause`
- **THEN** la simulación se detiene y el HUD muestra el estado de pausa

#### Scenario: Reinicio

- **WHEN** el jugador pulsa `restart` en cualquier estado
- **THEN** el nivel se recarga con 3 vidas y 0 puntos

### Requirement: HUD del nivel

El HUD DEBE (MUST) mostrar vidas, puntuación, arma activa y mensajes de pausa, game over y victoria.

#### Scenario: Actualización del HUD

- **WHEN** cambian las vidas, la puntuación, el arma o el estado
- **THEN** el HUD refleja el valor actual

#### Scenario: Mensaje de fin

- **WHEN** la sesión está en `GAME_OVER` o `VICTORY`
- **THEN** el HUD muestra un mensaje para reiniciar
