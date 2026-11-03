# Design: playable-slice

## Context

El juego ya tiene movimiento, combate, terreno destructible y sesión. Falta un nivel con objetivos. Ver `proposal.md` y las specs de `enemies`, `rescue-system`, `level-flow` y `game-session`.

## Goals / Non-Goals

**Goals:** enemigos básicos, POWs, muerte/reaparición, checkpoint, salida, victoria, game over, pausa, reinicio y HUD.

**Non-Goals:** jefes, múltiples niveles, guardado, arte/audio final, pathfinding complejo, colapso de terreno.

## Decisions

### D1. Enemigos por composición con `Health`

- `Grunt` (`CharacterBody2D`, capa 2, máscara 1): persigue horizontalmente, aplica gravedad, `move_and_slide`, daña al jugador a menos de 18 px y muere con 30 de salud.
- `Kamikaze` (`Area2D`, capa 2): vuela hacia el jugador, daña y muere a menos de 14 px, y muere con 10 de salud.

Ambos emiten `died(points)` y se añaden al grupo `enemies`. El nivel conecta la señal para sumar puntos. No se usa pathfinding: el nivel es plano con plataformas y el jugador es el objetivo directo.

### D2. POW y checkpoint

`Pow` (`Area2D`) detecta al jugador por distancia, emite `rescued` una sola vez y se libera. El nivel:

- Suma una vida (`session.add_life()`).
- Suma 500 puntos.
- Actualiza el checkpoint a la posición del POW.

### D3. Muerte y reaparición

`Player` añade `alive`, `invulnerable`, `died` y `take_damage()`. Al morir se oculta y desactiva su física. El nivel:

1. Llama `session.lose_life()`.
2. Si queda game over, deja la sesión en `GAME_OVER`.
3. Si quedan vidas, espera 0.6 s y llama `player.respawn(checkpoint)`, que restaura posición, velocidad, visibilidad y 1 s de invulnerabilidad.

Caer por debajo de `y = 320` cuenta como muerte.

### D4. Nivel y salida

`DestructibleTerrain` se parametriza con `rebuild(width, height, ground_rows, platforms)`. El nivel 01 usa 120×34 celdas (960×272 px), suelo de 6 filas y plataformas en alturas variadas.

La salida es un nodo visual en `(920, 200)`; el nivel comprueba la distancia al jugador y llama `session.win()`.

### D5. Sesión y flujo

`GameSession` añade `State.VICTORY`, `win()` (solo desde `PLAYING`), `is_victory()` y `add_life()`. El reinicio ya existente funciona desde cualquier estado.

El nivel usa `SessionController` para pausa/reinicio. En `PAUSED` se pausa el árbol (`get_tree().paused = true`), con nivel, controlador y HUD en `PROCESS_MODE_ALWAYS`. En `GAME_OVER`/`VICTORY` se desactiva la física del jugador y de los enemigos, sin pausar el árbol. `restart` recarga la escena.

### D6. HUD

`level.gd` actualiza un `CanvasLayer` con etiquetas de vidas, puntuación, arma y mensaje central. Se conecta a las señales de sesión y `weapon_changed`. En `PAUSED`, `GAME_OVER` y `VICTORY` muestra el mensaje correspondiente con la indicación de reinicio.

### D7. Escena principal y debug

`scenes/level_01.tscn` pasa a ser la escena principal. `scenes/debug_session.tscn` se conserva como banco de pruebas con dummy, botones y explosión. `test_project_settings.gd` se actualiza.

### D8. Tests

- `test_game_session.gd`: victoria y vida extra.
- `test_enemies.gd`: persecución, daño por contacto, daño de bala, muerte y puntuación.
- `test_rescue.gd`: rescate, recompensa, checkpoint y no doble rescate.
- `test_level.gd`: carga, terreno 120, jugador, enemigos, POWs, salida, muerte/reaparición, victoria, HUD y reinicio.
- `test_debug_session.gd` sigue cubriendo el banco de pruebas.

## Risks / Trade-offs

| Riesgo | Mitigación |
|---|---|
| Enemigos atraviesan el terreno | Grunt con colisión y gravedad; kamikaze vuela, aceptado |
| El jugador reaparece dentro de un enemigo | 1 s de invulnerabilidad y checkpoint en POW/salida |
| La pausa congela el HUD | Nivel, controlador y HUD con `PROCESS_MODE_ALWAYS` |
| Game over/victoria bloquean los tests | No se pausa el árbol en esos estados; solo se desactiva física |
| La escena principal cambia y rompe tests | Actualizar `test_project_settings` y README en la misma task |
| Nivel demasiado largo para el slice | 960 px, 5 enemigos y 2 POWs; ajuste manual |

## Migration Plan

No hay datos. Se añaden escenas y scripts; la escena principal cambia a `level_01.tscn`. Rollback: restaurar `debug_session.tscn` como principal y eliminar los archivos nuevos.

## Open Questions

Ninguna que afecte al alcance. El balance exacto se ajusta en playtest.
