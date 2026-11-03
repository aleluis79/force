# Tasks: bootstrap-project

## 1. Repositorio y proyecto Godot

- [x] 1.1 Inicializar git en `main`, crear `.gitignore` de Godot 4 (`.godot/`, `export/`, `.DS_Store`) y `.gitattributes` (`* text=auto eol=lf`, `*.png binary`). Verificación: `git status` muestra solo los archivos esperados y `.godot/` no aparece como trackeable.
- [x] 1.2 Crear `project.godot` con nombre `Force`, escena principal, renderer `gl_compatibility`, resolución 480×270, ventana 1440×810, filtro nearest, pixel snap, física a 60 Hz y la estructura `src/{core,entities,world,presentation,autoload}`, `tests/{unit,integration,helpers}`, `scenes/`, `assets/`, `docs/adr/`, `scripts/` (con `.gitkeep` donde haga falta). Verificación: `godot --headless --path . --quit` termina con código 0 y sin errores de script.
- [x] 1.3 Crear `scenes/bootstrap.tscn` con raíz `Node2D` llamada `Bootstrap`, un `ColorRect` de 480×270 y una etiqueta de texto. Verificación: `godot --headless --path . --quit-after 60` termina con código 0 y la escena se instancia sin errores.

## 2. GUT y puerta de calidad

- [x] 2.1 Vendorizar GUT 9.7.1 (tag `v9.7.1`, rama `godot_4_7`) en `addons/gut/`, habilitar el plugin en `project.godot` y añadir `tests/unit/.gitkeep`. Verificación: `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit` arranca GUT y termina con código 0.
- [x] 2.2 Crear `scripts/test.sh` que resuelva `GODOT_BIN` (con fallback a la ruta instalada), ejecute GUT headless, aborte si GUT falla y luego ejecute `openspec validate --all --strict`. Verificación: el script termina con código 0 con la suite actual; al añadir temporalmente un test que falla, termina con código distinto de cero y muestra el nombre del test; al quitarlo, vuelve a 0.
- [x] 2.3 Crear `README.md` con requisitos, cómo abrir el proyecto, cómo ejecutar el juego, `GODOT_BIN`, `scripts/test.sh`, estructura de carpetas y flujo SDD/TDD. Verificación: los comandos copiados del README funcionan tal cual en una terminal limpia.

## 3. Configuración verificable, input y lógica pura

- [x] 3.1 Escribir `tests/unit/test_project_settings.gd` que verifique resolución interna 480×270, ventana 1440×810, `stretch` con proporción conservada, filtro nearest, pixel snap, renderer `gl_compatibility` y 60 ticks de física. Verificación: `./scripts/test.sh` pasa y el test falla si se cambia manualmente cualquiera de esos valores.
- [x] 3.2 Escribir primero `tests/unit/test_input_map.gd` (11 acciones, bindings de teclado/ratón y gamepad, pausa y reinicio sin ratón); ejecutarlo en rojo y después definir el `InputMap` en `project.godot` según la tabla del design. Verificación: el test pasa y falla si se elimina una acción o un binding.
- [x] 3.3 Escribir primero `tests/unit/test_deterministic_rng.gd` (misma semilla produce la misma secuencia, semillas distintas difieren, reiniciar reproduce); implementar `src/core/deterministic_rng.gd` como `RefCounted` con semilla explícita. Verificación: el test pasa y `src/core/deterministic_rng.gd` no usa `randf()` ni `randi()` globales.
- [x] 3.4 Escribir `tests/unit/test_core_isolation.gd` que recorra `src/core`, ignore comentarios y falle ante `Input.`, `get_tree(`, `Time.`, `randf(`, `randi(` u `OS.get_ticks`, indicando archivo y línea. Verificación: el test pasa con el core actual y falla al añadir temporalmente una referencia prohibida en un archivo de `src/core`.

## 4. Smoke test, documentación y contexto OpenSpec

- [x] 4.1 Escribir `tests/integration/test_bootstrap_smoke.gd` que cargue `res://scenes/bootstrap.tscn`, la añada al árbol, espere 60 frames de física y verifique que la raíz `Bootstrap` sigue viva y con el tamaño interno esperado. Verificación: el test pasa en headless y falla si se cambia el nombre de la raíz o se rompe la escena.
- [x] 4.2 Crear `docs/adr/0001-foundation-stack.md` con contexto, decisión, alternativas y consecuencias de motor, GUT, resolución/escalado, separación core/nodos y comando de calidad; incluir fecha y estado `Aceptado`. Verificación: el ADR cubre los cinco temas y enlaza a `scripts/test.sh`.
- [x] 4.3 Actualizar `openspec/config.yaml` con contexto del proyecto y reglas de `proposal`, `specs`, `design` y `tasks` (español, DEBE, escenarios con ID, alternativas, tasks ≤2 h y test antes de implementación). Verificación: `openspec context --json` funciona y `openspec instructions proposal --change bootstrap-project --json` incluye las reglas añadidas.
- [x] 4.4 Verificación de integración: borrar `.godot/`, ejecutar `./scripts/test.sh` desde cero y confirmar que GUT reimporta, todos los tests pasan, `openspec validate --all --strict` pasa y el código de salida es 0.

## Workflow follow-up

- Revisar el diff completo y confirmar que no se implementó gameplay fuera del alcance.
- Ejecutar `openspec validate --all --strict` una última vez.
- Archivar el change con `/opsx-archive` cuando la revisión esté aprobada.
