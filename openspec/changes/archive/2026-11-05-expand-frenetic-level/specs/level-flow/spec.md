# Spec Delta

## MODIFIED Requirements

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

## ADDED Requirements

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
