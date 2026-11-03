# Spec Delta: combat

## Purpose

Define el combate del jugador: salud y daño, armas con cadencia y dispersión, disparo con retroceso, balas con pooling, impacto en objetivos y terreno, y hitstop.

## ADDED Requirements

### Requirement: Salud y daño

La salud DEBE (MUST) tener un máximo, un valor actual, recibir solo daño positivo y llegar a cero sin valores negativos.

#### Scenario: Recibir daño

- **WHEN** un objetivo con 100 de salud recibe 30 de daño
- **THEN** su salud actual queda en 70 y sigue vivo

#### Scenario: Daño letal

- **WHEN** un objetivo recibe daño igual o mayor que su salud actual
- **THEN** su salud queda en 0 y se emite la señal de muerte

#### Scenario: Daño inválido

- **WHEN** se aplica daño cero o negativo
- **THEN** la salud no cambia

### Requirement: Armas y cadencia

El juego DEBE (MUST) ofrecer un rifle automático y una escopeta semiautomática con daño, cadencia, dispersión y número de proyectiles propios.

#### Scenario: Rifle automático

- **WHEN** el jugador mantiene el disparo con el rifle
- **THEN** se dispara repetidamente respetando la cadencia

#### Scenario: Escopeta semiautomática

- **WHEN** el jugador mantiene el disparo con la escopeta
- **THEN** solo se dispara una vez por pulsación

#### Scenario: Dispersión de escopeta

- **WHEN** la escopeta dispara
- **THEN** genera varios proyectiles repartidos dentro de su ángulo de dispersión

### Requirement: Disparo del jugador

El jugador DEBE (MUST) disparar en la dirección de apuntado al activar `shoot`, respetando el cooldown del arma y aplicando retroceso en dirección contraria al apuntado.

#### Scenario: Disparo en la dirección de apuntado

- **WHEN** el jugador apunta a la derecha y dispara
- **THEN** las balas salen hacia la derecha

#### Scenario: Cooldown

- **WHEN** el arma todavía está en cooldown
- **THEN** no se genera otro proyectil

#### Scenario: Retroceso

- **WHEN** el jugador dispara
- **THEN** su velocidad recibe un impulso contrario a la dirección de apuntado

### Requirement: Balas y pooling

Las balas DEBEN (MUST) moverse, expirar por tiempo de vida y reutilizarse mediante un pool con un límite de balas activas.

#### Scenario: Reutilización de balas

- **WHEN** una bala termina su vida y se dispara otra
- **THEN** el pool reutiliza una instancia inactiva

#### Scenario: Límite de balas activas

- **WHEN** el pool alcanza su máximo de balas activas
- **THEN** no crea más balas hasta que alguna termine

#### Scenario: Expiración

- **WHEN** una bala supera su tiempo de vida sin impactar
- **THEN** vuelve al pool y deja de procesarse

### Requirement: Impacto en objetivos

Una bala DEBE (MUST) dañar al primer objetivo con `take_damage` que encuentre y DEBE notificar el impacto para el hitstop.

#### Scenario: Impacto en objetivo

- **WHEN** una bala alcanza un objetivo con salud
- **THEN** le aplica su daño, termina y emite una señal de impacto

#### Scenario: Objetivo destruido

- **WHEN** la salud del objetivo llega a 0
- **THEN** el objetivo deja de ser dañable y emite su muerte

### Requirement: Impacto en terreno

Una bala DEBE (MUST) destruir terreno al impactar contra una celda sólida y DEBE terminar en ese impacto.

#### Scenario: Bala contra terreno

- **WHEN** una bala entra en una celda sólida
- **THEN** se destruye un pequeño radio de terreno y la bala vuelve al pool

### Requirement: Hitstop

Al confirmar un impacto, la escena de depuración DEBE (MUST) aplicar una congelación breve y DEBE restaurar la escala de tiempo.

#### Scenario: Congelación breve

- **WHEN** una bala impacta en un objetivo
- **THEN** la escala de tiempo baja brevemente y vuelve a 1.0

### Requirement: Escena de depuración de combate

La escena de depuración DEBE (MUST) incluir un objetivo de práctica y botones para elegir rifle o escopeta, manteniendo el HUD y el terreno destructible.

#### Scenario: Objetivo de práctica

- **WHEN** el jugador dispara al objetivo
- **THEN** su salud disminuye y el HUD de sesión sigue funcionando

#### Scenario: Cambio de arma

- **WHEN** el jugador pulsa el botón de rifle o escopeta
- **THEN** el arma activa cambia y el siguiente disparo usa sus estadísticas
