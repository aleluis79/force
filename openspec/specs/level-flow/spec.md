# level-flow Specification

## Purpose

Define el nivel jugable, la muerte y reaparición del jugador, la salida, la victoria, el game over, la pausa, el reinicio y el HUD.

## Requirements

### Requirement: Nivel jugable

El nivel DEBE (MUST) tener 3840 px de ancho, terreno destructible con al menos 25 plataformas, jugador, al menos 30 enemigos, al menos 8 prisioneros y una salida al final.

#### Scenario: Carga del nivel

- **WHEN** se carga el nivel
- **THEN** el jugador aparece sobre el terreno y existen al menos 30 enemigos, 8 prisioneros, 25 plataformas y una salida

#### Scenario: Cámara del nivel

- **WHEN** el jugador avanza hacia la derecha
- **THEN** la cámara lo sigue dentro de los límites del nivel extendido

#### Scenario: Salida al final

- **WHEN** el jugador recorre el nivel hasta el extremo derecho
- **THEN** encuentra la salida más allá de los 3700 px

### Requirement: Plataformas usables

Todas las plataformas del nivel DEBEN (MUST) ser alcanzables mediante saltos desde el suelo o desde otra plataforma alcanzable, DEBEN (MUST) tener superficie sólida y espacio libre encima, y no DEBEN (MUST NOT) solaparse con el suelo ni entre sí.

#### Scenario: Alcanzabilidad

- **WHEN** se analiza la secuencia de plataformas desde el suelo
- **THEN** cada plataforma se puede alcanzar con la altura y distancia horizontal del salto del jugador

#### Scenario: Superficie pisable

- **WHEN** se inspecciona cualquier plataforma
- **THEN** su fila superior tiene celdas sólidas y la fila inmediatamente superior está libre

#### Scenario: Sin solapes

- **WHEN** se comparan las plataformas entre sí y con el suelo
- **THEN** ninguna plataforma invade otra plataforma ni las filas de terreno

#### Scenario: Aterrizaje real

- **WHEN** el jugador cae sobre una plataforma alta
- **THEN** aterriza sobre ella y queda apoyado

### Requirement: Muerte y reaparición

El jugador DEBE (MUST) morir solo cuando su salud llegue a 0, perder una vida y reaparecer con salud completa en el checkpoint si le quedan vidas.

#### Scenario: Muerte con vidas

- **WHEN** la salud del jugador llega a 0 y tiene vidas restantes
- **THEN** pierde una vida y reaparece en el checkpoint con salud completa e invulnerabilidad breve

#### Scenario: Última vida

- **WHEN** la salud del jugador llega a 0 sin vidas restantes
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

### Requirement: Barra de salud en el HUD

El HUD del nivel DEBE (MUST) mostrar una barra con la salud actual y máxima del jugador, actualizada al recibir daño y al reaparecer.

#### Scenario: Actualización al recibir daño

- **WHEN** el jugador recibe daño
- **THEN** la barra de salud refleja el nuevo valor actual

#### Scenario: Reaparición con salud completa

- **WHEN** el jugador reaparece tras perder una vida
- **THEN** la barra de salud vuelve a mostrarse llena
