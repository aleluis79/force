# Design

## Context

Ver `proposal.md` para la motivación y el delta de `level-flow` para el contrato. El nivel actual define sus plataformas en `level.gd`, pero los enemigos, POWs y la salida están escritos a mano en `level_01.tscn`. La física del jugador salta unos 50 px de altura y alcanza ~80 px horizontales en un salto completo. El ancho actual es 240 celdas de 8 px.

## Goals / Non-Goals

**Goals:**

- Aumentar el nivel a 480 celdas (3840 px) sin perder legibilidad ni rendimiento.
- Diseñar plataformas con una ruta garantizada y verificable.
- Aumentar la densidad de combate de forma data-driven y mantenible.
- Verificar automáticamente que las plataformas son sólidas, alcanzables y pisables.

**Non-Goals:**

- Nuevos tipos de enemigo, jefes, checkpoints múltiples o cambios de arte.
- Rebalanceo completo de daño o munición.
- Editor visual de niveles.

## Decisions

### 1. Nivel de 480×34 celdas

El nivel duplica el ancho actual a 480 celdas (3840 px), mantiene 34 filas y 6 filas de suelo. La cámara queda limitada por `terrain.width * TILE_SIZE`.

- **Alternativa descartada:** 960 celdas. Aumenta mucho el tiempo de recorrido y el coste de tests sin aportar una mejora proporcional al vertical slice.

### 2. Plataformas generadas por patrón

Se generan 28 plataformas de 10 celdas de ancho, separadas por 6 celdas (48 px), con filas alternadas `[24, 20, 16, 20, 24]`. Cada salto sube o baja 4 celdas (32 px), dentro del salto máximo de 50 px, y el hueco horizontal de 48 px queda por debajo del alcance de ~80 px.

- **Alternativa descartada:** plataformas manuales dispersas. Dificulta garantizar alcanzabilidad y mantenimiento.
- **Alternativa descartada:** plataformas de gran altura con huecos largos. Ya existen en el nivel actual y algunas no son alcanzables con la física real.

### 3. Spawns data-driven en el nivel

Los enemigos, POWs y su distribución se definen en arrays de `level.gd` y se instancian en `_ready`. La escena queda con jugador, terreno, fondo, decoración, salida y HUD. Los nombres `Grunt1`, `Pow1`, etc. se conservan para compatibilidad con tests y depuración.

- **Alternativa descartada:** escribir 38 enemigos y 8 POWs a mano en el `.tscn`. Es verboso, propenso a errores y difícil de validar.
- **Alternativa descartada:** un spawner global. Añade una capa de indirección innecesaria para un solo nivel.

### 4. Densidad y presión de disparo

Se usan 26 soldados (12 en suelo y 14 sobre plataformas alternas) y 12 kamikazes, para 38 enemigos. La cadencia del soldado baja de 1.4 s a 0.9 s y su rango sube a 300 px. Esto mantiene proyectiles activos sin llenar la pantalla de forma ilegible.

- **Alternativa descartada:** duplicar el daño enemigo. Vuelve el combate injusto y reduce la utilidad de la barra de salud.
- **Alternativa descartada:** 80 enemigos. Satura el rendimiento y hace que el nivel sea una pared de proyectiles.

### 5. Verificación geométrica de plataformas

Un test construye el grafo de plataformas desde el suelo usando un salto conservador (44 px de subida y 56 px de hueco horizontal), comprueba que todas son alcanzables, que su fila superior es sólida, que la fila superior está libre y que no hay solapes. Otro test deja caer al jugador sobre una plataforma alta y verifica que aterriza.

- **Alternativa descartada:** confiar solo en inspección visual. No es repetible en headless ni detecta regresiones.
- **Alternativa descartada:** simular todos los saltos frame a frame. Es lento y frágil; la cota conservadora cubre el caso de uso.

## Risks / Trade-offs

- [Más enemigos reducen el rendimiento headless] → Se usan 38 enemigos y se mantiene el pool de balas; la suite se ejecuta en menos de un minuto.
- [La cota de salto puede ser conservadora y rechazar una plataforma alcanzable] → El diseño usa 32 px de subida y 48 px de hueco, con margen amplio.
- [Los spawns enemigos pueden caer fuera de una plataforma] → Se calculan a partir del rectángulo de plataforma y se verifica el aterrizaje.
- [La escena pierde nodos editables a mano] → Los arrays quedan centralizados y documentados en `level.gd`.

## Migration Plan

- Sustituir el array de plataformas y la llamada a `terrain.rebuild`.
- Eliminar enemigos/POWs manuales del `.tscn` y moverlos a spawns.
- Actualizar el límite de cámara, la salida y los tests de conteo.
- Rollback: restaurar el array y los nodos anteriores del `.tscn`.

## Open Questions

Ninguna que afecte a specs, alcance o tareas.
