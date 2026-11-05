# enemies Specification

## Purpose

Define enemigos básicos con IA de persecución, daño por contacto, salud, muerte y puntuación para el vertical slice.

## Requirements

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

### Requirement: Soldado con ataque a distancia

El soldado enemigo DEBE (MUST) disparar proyectiles hacia el torso del jugador cuando esté dentro de su rango de tiro y su cadencia lo permita.

#### Scenario: Disparo dentro del rango

- **WHEN** el jugador está dentro del rango de tiro del soldado y este tiene el arma lista
- **THEN** el soldado genera un proyectil dirigido a la altura del torso del jugador

#### Scenario: Cadencia limitada

- **WHEN** el soldado acaba de disparar y el jugador sigue en rango
- **THEN** no dispara otro proyectil hasta que pase su intervalo de disparo

#### Scenario: Fuera de rango

- **WHEN** el jugador está fuera del rango de tiro del soldado
- **THEN** el soldado no genera proyectiles

#### Scenario: Soldado muerto

- **WHEN** el soldado muere
- **THEN** deja de disparar proyectiles
