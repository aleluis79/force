# Design

## Context

Ver `proposal.md` para la motivación y los delta specs para el comportamiento. El jugador actual muere con cualquier daño y los enemigos solo dañan por contacto. El sistema de vidas y checkpoints ya existe en `GameSession` y `Level`. El combate usa balas con pooling, raycast contra la capa de enemigos y hitstop. La entrada está abstraída en `InputSource`.

## Goals / Non-Goals

**Goals:**

- Añadir salud numérica al jugador sin romper vidas, checkpoints ni reaparición.
- Introducir proyectiles enemigos como entidades destructibles e independientes de las balas del jugador.
- Permitir agacharse con una reducción real del hitbox, no solo visual.
- Mantener la lógica determinista y testeable en headless.

**Non-Goals:**

- Animación dibujada de agacharse, IA de cobertura, línea de visión compleja o nuevos enemigos.
- Rebalanceo completo de daño, munición o dificultad.
- Barra de salud de enemigos o cambios al sistema de puntuación.

## Decisions

### 1. Salud del jugador con `Health`

`Player` incorpora una instancia de `Health` (100 por defecto), conecta `damaged` y `died` a señales del jugador y expone `health_changed(current, max)`. El daño por contacto y por proyectil usa la misma ruta `take_damage(amount)`. La muerte solo ocurre cuando `Health` llega a 0.

- **Alternativa descartada:** usar corazones o un contador entero en `Player`. Duplicaría la lógica de señales y no reutilizaría la clase pura ya probada.
- **Alternativa descartada:** mantener muerte de un golpe y mostrar una barra decorativa. No cumple el objetivo de esquivar y sobrevivir a varios impactos.

### 2. Invulnerabilidad temporal compartida

`Player` reutiliza su temporizador de invulnerabilidad para dos casos: 1.0 s al reaparecer y ~0.6 s tras recibir daño. Durante la ventana, `take_damage` devuelve 0 y no altera la salud.

- **Alternativa descartada:** un segundo temporizador independiente. Añade estado y permite solapamientos difíciles de razonar.

### 3. Proyectil enemigo como entidad propia

Se crea `EnemyBullet` (`Area2D`) con sprite tenue/rojizo, movimiento recto, vida útil y detección por raycast contra la capa del jugador/terreno. Su capa de colisión es la 3 (valor 4); las balas del jugador amplían su máscara a enemigos + proyectiles (`2 | 4`). El proyectil implementa `take_damage` para que una bala del jugador lo destruya con un impacto.

- **Alternativa descartada:** reutilizar `Bullet` para enemigos. La bala del jugador está acoplada al pool y a la capa 2; mezclar ambos usos complica el pooling y la destrucción mutua.
- **Alternativa descartada:** detectar proyectiles por grupo y distancia. El raycast existente ya resuelve impactos de forma determinista y respeta la máscara.

### 4. Disparo enemigo por acumulador en física

`Grunt` acumula tiempo en `_physics_process`. Cuando el jugador está dentro del rango, vivo y el acumulador supera el intervalo, dispara un `EnemyBullet` hacia `player.global_position + Vector2(0, AIM_HEIGHT)`. El proyectil se añade al padre del enemigo para no heredar su movimiento.

- **Alternativa descartada:** `Timer` hijo por enemigo. Más nodos y difícil de manipular en tests headless.
- **Alternativa descartada:** disparo instantáneo por raycast. No permite esquivar ni destruir el proyectil.

### 5. Agacharse con textura y shape dedicados

`Player` conserva un shape de pie y otro agachado duplicados en runtime. Al agacharse en el suelo, cambia la altura (28 → 20 px), desplaza el centro del collider para mantener los pies en el mismo punto y cambia a una textura de cuerpo agachado generada a partir del sprite original: la cabeza y el torso se mantienen sin deformar, las piernas se comprimen y el arma baja al nuevo hombro. La velocidad horizontal se limita a un máximo reducido mientras está agachado.

- **Alternativa descartada:** escalar el sprite completo en vertical. Deformaba la cabeza y se leía como un sprite aplastado, no como un personaje agachado.
- **Alternativa descartada:** escalar el `CollisionShape2D` completo. En Godot eso deforma el shape compartido entre instancias de escena y complica los tests.
- **Alternativa descartada:** hitbox separado solo para daño. El jugador seguiría chocando como si estuviera de pie y la acción no se leería.

### 6. Barra de salud con `ProgressBar`

El HUD del nivel usa un `ProgressBar` con valor máximo 100, sin porcentaje visible y con estilos pixel art. `Level` conecta `player.health_changed` y actualiza `value`.

- **Alternativa descartada:** dos `ColorRect` animados a mano. Más código de presentación y sin valor numérico verificable de forma directa.

## Risks / Trade-offs

- [El jugador puede intentar levantarse bajo un techo y quedar solapado] → Se agacha solo en el suelo y el nivel actual no tiene techos bajos; se documenta como limitación.
- [La ventana de invulnerabilidad puede hacer que varios proyectiles parezcan no dañar] → Es intencional para evitar muertes por ráfagas; se prueba que solo aplica el primer impacto.
- [Cambiar la máscara de las balas del jugador puede hacer que impacten objetos no deseados] → Solo se añade la capa 3 de proyectiles enemigos; las balas del jugador permanecen en la capa 0 para no autoimpactarse.
- [Duplicar shapes en runtime puede olvidar restaurar el original] → Se centraliza en un método `_apply_crouch_collision` y se prueba el ciclo agacharse/soltar.

## Migration Plan

- Los tests existentes que asumen muerte de un golpe se actualizan para aplicar daño letal explícito.
- El daño por contacto deja de ser letal inmediato; los tests pasan a comprobar reducción de salud.
- Rollback: revertir los archivos del change y restaurar las specs principales desde `openspec/specs/` si fuera necesario.

## Open Questions

Ninguna que afecte a specs, alcance o tareas. El balance exacto de daño y cadencia se puede ajustar en playtest sin cambiar el contrato.
