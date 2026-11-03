# Design: bootstrap-project

## Context

Proyecto greenfield: el repositorio solo contiene `openspec/` y `.opencode/`. No hay `project.godot`, ni git, ni tests. Godot 4.7.2 stable está instalado fuera del repo y GUT 9.7.1 es la versión publicada para Godot 4.7.x. Ver `proposal.md` para la motivación.

Restricciones relevantes:

- El binario de Godot no está en `PATH`; la ruta debe ser configurable.
- El proyecto debe funcionar sin editor: la puerta de calidad es un comando local headless.
- La lógica de juego posterior debe ser testeable sin escenas; la base debe imponer esa separación desde el primer commit.
- Los artifacts de OpenSpec se escriben en español; el código y los nombres de tests, en inglés.

## Goals / Non-Goals

**Goals:**

- Un proyecto Godot que arranca y se cierra limpio en headless.
- Una suite GUT ejecutable con un solo comando y con código de salida correcto.
- Configuración pixel-perfect verificable y documentada.
- Un `InputMap` estable que el futuro controlador de jugador pueda consumir sin renombrar acciones.
- Una regla automática que impida que `src/core` dependa de nodos, `Input` global o RNG global.
- Un ciclo TDD demostrado con un test unitario real y un smoke test de escena.

**Non-Goals:**

- Implementar movimiento, disparo, destrucción, enemigos o rescates.
- Generar arte, audio o niveles.
- Configurar exportación, CI remota o firma de binarios.
- Decidir el título definitivo, icono o fuente pixel final.

## Decisions

### D1. Motor y lenguaje: Godot 4.7.2 + GDScript tipado

Se usa la versión ya instalada y GDScript con tipado estático. Para un arcade 2D, GDScript elimina fricción de build, se integra con el editor y es suficiente para el presupuesto de rendimiento del slice.

**Alternativas:** C# (build más pesado y sin ventaja clara para 2D), Unity (fuera del stack elegido), Godot 4.6 (GUT 9.7.1 requiere 4.7.x).

### D2. GUT 9.7.1 vendorizado

Se descarga el tag `v9.7.1` (rama `godot_4_7`) y se commitea `addons/gut/` completo. No se usa submódulo: el repo debe clonarse y testearse sin pasos extra. El plugin se habilita en el editor, pero el CLI funciona sin abrir el editor.

**Alternativas:** gdUnit4 (más funciones de mocking, pero GUT ya cubre lo necesario), runner casero (reinventa reporte y filtros).

**Comando base:**

```bash
"$GODOT_BIN" --headless --path "$ROOT" \
  -s addons/gut/gut_cmdln.gd \
  -gdir=res://tests -ginclude_subdirs -gexit
```

GUT en headless termina solo y devuelve código de error si hay fallos.

### D3. Resolución y escalado

| Setting | Valor |
|---|---|
| `display/window/size/viewport_width` | `480` |
| `display/window/size/viewport_height` | `270` |
| `display/window/size/window_width_override` | `1440` |
| `display/window/size/window_height_override` | `810` |
| `display/window/stretch/mode` | `canvas_items` |
| `display/window/stretch/aspect` | `keep` |
| `display/window/stretch/scale_mode` | `integer` |
| `rendering/textures/canvas_textures/default_texture_filter` | `0` (nearest) |
| `rendering/2d/snap/snap_2d_transforms_to_pixel` | `true` |
| `rendering/2d/snap/snap_2d_vertices_to_pixel` | `true` |
| `rendering/renderer/rendering_method` | `gl_compatibility` |
| `physics/common/physics_ticks_per_second` | `60` |

**Por qué 480×270:** permite tiles de 16 px y celdas de destrucción de 8 px con suficiente detalle, mantiene el look pixel art y escala exacto a 1440×810 (3×) y 1920×1080 (4×). 320×180 daría píxeles más gruesos y menos espacio para HUD; 640×360 diluye el look.

**Alternativas:** `stretch/mode=viewport` (pixel perfect pero escala también UI y complica el texto), escalado fraccional (bordes borrosos). `canvas_items` + `integer` conserva la nitidez y permite UI nítida a resolución interna.

Los nombres exactos de las propiedades se verifican contra Godot 4.7.2 durante la primera task; si `scale_mode` cambió, se ajusta sin cambiar el comportamiento exigido por la spec.

### D4. Arquitectura: lógica pura vs nodos

```
src/core/          RefCounted puro, sin Node, sin autoloads
src/entities/      Escenas que orquestan core (player, enemy, bullet)
src/world/         Terreno, nivel, spawner
src/presentation/  Cámara, VFX, HUD, audio
src/autoload/      Event bus y sesión: solo glue
tests/unit/        Pruebas de core
tests/integration/ Escenas headless con SimulationHarness
tests/helpers/     Harness, inputs guionizados, fixtures
```

Regla de dependencia: `core` no importa nada de `entities`, `world`, `presentation` ni `autoload`. Los nodos pueden depender de `core`, nunca al revés. Las dependencias externas (RNG, input, tick) se inyectan por constructor o método.

La utilidad de ejemplo del bootstrap será `src/core/deterministic_rng.gd`, un wrapper de `RandomNumberGenerator` con semilla explícita. Sirve para demostrar el patrón y será reutilizada por el gameplay.

**Alternativas:** lógica dentro de los nodos (tests lentos y acoplados), autoload global para todo (oculta dependencias y rompe determinismo).

### D5. Guardia de aislamiento de `src/core`

`tests/unit/test_core_isolation.gd` recorre `res://src/core` con `DirAccess`, lee cada `.gd`, elimina comentarios de línea y busca tokens prohibidos: `Input.`, `get_tree(`, `Time.`, `randf(`, `randi(`, `OS.get_ticks`. Si encuentra uno, falla con `archivo:línea` y el token.

**Alternativas:** revisión manual (no escala), linter externo (dependencia innecesaria para una regla simple). Se acepta el riesgo de falsos positivos en strings; si aparece, se documenta la excepción en el test.

### D6. `InputMap` inicial

| Acción | Teclado / ratón | Gamepad |
|---|---|---|
| `move_left` | A, flecha izquierda | stick izquierdo −X, D-pad izquierda |
| `move_right` | D, flecha derecha | stick izquierdo +X, D-pad derecha |
| `aim_left` | — | stick derecho −X |
| `aim_right` | — | stick derecho +X |
| `aim_up` | — | stick derecho −Y |
| `aim_down` | — | stick derecho +Y |
| `jump` | Espacio | botón A |
| `shoot` | clic izquierdo | gatillo derecho (RT) |
| `special` | clic derecho | gatillo izquierdo (LT) |
| `pause` | Esc | Start |
| `restart` | R | Back/Select |

El apuntado con ratón se resolverá en el controlador con la posición global del puntero, no con una acción booleana. Las acciones `aim_*` existen para gamepad y para tests de input guionizado.

**Alternativas:** un único `aim` analógico (InputMap no compone ejes), aim con teclado (compite con el movimiento y no es Broforce-like).

### D7. Comando único de calidad

`scripts/test.sh`:

1. Resuelve `GODOT_BIN` (variable de entorno) o usa la ruta instalada.
2. Ejecuta GUT headless con `-gdir=res://tests -ginclude_subdirs -gexit`.
3. Si GUT falla, termina con ese código sin ejecutar la validación.
4. Ejecuta `openspec validate --all --strict`.
5. Devuelve 0 solo si ambas partes pasan.

**Alternativas:** dos comandos separados (fácil olvidar uno), pre-commit hook (no siempre instalado). El script es la fuente de verdad; un hook puede llamarlo más adelante.

### D8. Smoke test de arranque

`tests/integration/test_bootstrap_smoke.gd` carga `res://scenes/bootstrap.tscn`, la añade al árbol, espera 60 frames de física y verifica que el nodo raíz sigue vivo y que la escena tiene el tamaño interno esperado. No compara píxeles: la verificación visual del escalado es manual y queda documentada en el ADR.

La escena `bootstrap.tscn` es un `Node2D` con un `ColorRect` de 480×270 y una etiqueta de texto. No contiene gameplay.

### D9. Git y documentación

- `git init` con rama `main`.
- `.gitignore` de Godot 4: `.godot/`, `*.translation`, `export/`, `.DS_Store`.
- `.gitattributes`: `* text=auto eol=lf`, `*.png binary`, `*.import text`.
- Commits convencionales (`chore:`, `test:`, `feat:`, `docs:`).
- `docs/adr/0001-foundation-stack.md` con contexto, decisión, alternativas y consecuencias de D1–D4 y D7.

### D10. Contexto y reglas de OpenSpec

Se actualiza `openspec/config.yaml` con:

- Contexto: motor, resolución, separación core/nodos, idioma y flujo TDD.
- Reglas de `proposal`: alcance del slice y fuera de alcance explícito.
- Reglas de `specs`: escenarios Given/When/Then con ID estable, español, DEBE.
- Reglas de `design`: alternativas consideradas.
- Reglas de `tasks`: máximo ~2 h, test antes de implementación, referencia al escenario.

## Risks / Trade-offs

| Riesgo | Mitigación |
|---|---|
| GUT 9.7.1 no cubre algún caso de Godot 4.7.2 | Versión upstream oficial para 4.7.x; el smoke test detecta incompatibilidades de arranque |
| El pixel snap se ve distinto en editor y headless | El smoke test valida instanciación; el escalado se revisa con captura manual y queda en el ADR |
| `stretch/scale_mode=integer` no existe o cambia en 4.7.2 | Verificar en la primera task; si no existe, usar `canvas_items` + `keep` y documentar el fallback |
| El guard de aislamiento produce falsos positivos | Ignorar comentarios, reportar `archivo:línea`, permitir excepción documentada |
| El comando depende de una ruta absoluta de Godot | `GODOT_BIN` configurable y fallback documentado |
| Sin CI remota, la disciplina depende del desarrollador | `scripts/test.sh` como única puerta y checklist en tasks; CI se añade en un change posterior |
| Vendorizar GUT infla el repo | Se acepta por reproducibilidad; se actualiza solo con un change dedicado |

## Migration Plan

Greenfield: no hay datos ni usuarios que migrar. Rollback = eliminar los archivos creados por este change y volver al estado actual (`openspec/` + `.opencode/`). No hay cambios destructivos.

Orden de implementación: configuración del proyecto → GUT y comando → guard de aislamiento y test unitario → smoke test → ADR y config de OpenSpec. Cada paso con su test antes de la implementación.

## Open Questions

- Título definitivo, icono y fuente pixel: se pueden decidir más adelante sin cambiar specs ni arquitectura; el bootstrap usa `Force` y la fuente por defecto.
