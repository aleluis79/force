# audio Specification

## Purpose

Define el audio del juego: efectos de sonido para las acciones principales y música de nivel en loop.

## Requirements

### Requirement: Efectos de sonido

El juego DEBE (MUST) incluir SFX para disparo, escopeta, salto, impacto, explosión, rescate, muerte, daño y victoria.

#### Scenario: Catálogo de SFX

- **WHEN** se consulta el gestor de audio
- **THEN** todos los efectos principales están disponibles

#### Scenario: Efecto desconocido

- **WHEN** se intenta reproducir un efecto inexistente
- **THEN** no se produce un error

### Requirement: Música de nivel

El nivel DEBE (MUST) reproducir música en loop mientras se juega.

#### Scenario: Inicio de nivel

- **WHEN** se carga el nivel
- **THEN** la música comienza y se repite al terminar

### Requirement: Mapeo de eventos a audio

Las acciones de juego DEBEN (MUST) disparar sus SFX correspondientes.

#### Scenario: Disparo y salto

- **WHEN** el jugador dispara o salta
- **THEN** se reproduce el SFX correspondiente

#### Scenario: Impacto, explosión y rescate

- **WHEN** una bala impacta, se destruye terreno o se rescata un POW
- **THEN** se reproduce el SFX correspondiente

#### Scenario: Muerte y victoria

- **WHEN** el jugador muere o completa el nivel
- **THEN** se reproduce el SFX correspondiente
