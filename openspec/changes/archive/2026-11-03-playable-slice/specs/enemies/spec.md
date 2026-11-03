# Spec Delta: enemies

## Purpose

Define enemigos básicos con IA de persecución, daño por contacto, salud, muerte y puntuación para el vertical slice.

## ADDED Requirements

### Requirement: Soldado perseguidor

El soldado DEBE (MUST) caminar hacia el jugador, respetar la gravedad y dañarlo al contacto.

#### Scenario: Persecución

- **WHEN** el soldado está activo y el jugador está a un lado
- **THEN** se mueve horizontalmente hacia el jugador

#### Scenario: Contacto

- **WHEN** el soldado toca al jugador
- **THEN** el jugador recibe daño

### Requirement: Kamikaze volador

El kamikaze DEBE (MUST) volar hacia el jugador y explotar al contacto, dañándolo.

#### Scenario: Vuelo

- **WHEN** el kamikaze está activo
- **THEN** se mueve en línea recta hacia el jugador

#### Scenario: Impacto

- **WHEN** el kamikaze alcanza al jugador
- **THEN** el jugador recibe daño y el kamikaze muere

### Requirement: Salud y puntuación de enemigos

Los enemigos DEBEN (MUST) recibir daño de balas, morir al llegar a 0 de salud y otorgar puntuación al morir.

#### Scenario: Daño de bala

- **WHEN** una bala impacta en un enemigo
- **THEN** su salud disminuye

#### Scenario: Muerte y puntuación

- **WHEN** la salud de un enemigo llega a 0
- **THEN** el enemigo desaparece y la sesión suma su puntuación
