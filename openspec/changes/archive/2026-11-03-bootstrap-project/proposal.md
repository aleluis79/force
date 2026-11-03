# Proposal: bootstrap-project

## Why

El repositorio solo contiene el scaffolding de OpenSpec: no hay proyecto Godot, ni repositorio git, ni framework de tests, ni una forma reproducible de verificar cambios. Sin esa base, el desarrollo SDD/TDD del vertical slice dependería de pasos manuales y de decisiones de configuración no documentadas.

Este change crea el esqueleto mínimo y verificable sobre el que se construirán todas las capacidades de juego posteriores.

## What Changes

- Inicializar el repositorio git y el proyecto Godot 4.7.2 con GDScript tipado.
- Configurar presentación pixel-perfect: resolución interna 480×270, ventana 1440×810 (3×), filtro nearest, pixel snap y renderer `gl_compatibility`.
- Fijar la versión de GUT 9.7.1 (rama `godot_4_7`) dentro de `addons/gut` y habilitar su ejecución headless.
- Crear la estructura de carpetas que separa lógica pura (`src/core`), entidades, mundo, presentación y tests.
- Definir el `InputMap` inicial para teclado, ratón y gamepad con nombres de acción estables.
- Añadir `scripts/test.sh`, que ejecuta GUT headless y `openspec validate --strict` como única puerta de calidad local.
- Añadir un smoke test de arranque del proyecto y un test unitario de ejemplo sobre una utilidad de `src/core`, para demostrar el ciclo rojo-verde-refactor.
- Documentar las decisiones de motor, testing y resolución en ADRs.
- Actualizar `openspec/config.yaml` con el contexto del proyecto y las reglas de artifacts (specs en español, código en inglés, tasks de máximo ~2 h, tests antes de implementación).

**Fuera de alcance:** gameplay, personajes, armas, terreno destructible, enemigos, arte final, audio, niveles, exportación y CI en la nube. Nada de eso se implementa en este change.

## Capabilities

### New Capabilities

- `project-foundation`: arranque verificable del proyecto, ejecución reproducible de tests headless, configuración de presentación pixel-perfect, acciones de entrada estables y separación entre lógica pura y nodos.

### Modified Capabilities

Ninguna. No existen specs principales todavía.

## Impact

- **Nuevo:** `project.godot`, `icon.svg`, `scenes/bootstrap.tscn`, `src/core/`, `src/entities/`, `src/world/`, `src/presentation/`, `src/autoload/`, `tests/unit/`, `tests/integration/`, `tests/helpers/`, `addons/gut/`, `scripts/test.sh`, `docs/adr/`.
- **Nuevo:** repositorio git con `.gitignore` y `.gitattributes` para Godot 4.
- **Modificado:** `openspec/config.yaml` (contexto y reglas).
- **Dependencias:** Godot 4.7.2 ya instalado en `/home/alejandro/godot/Godot_v4.7.2-stable_linux.x86_64`; GUT 9.7.1 vendorizado.
- **Riesgo:** ninguno de gameplay; el riesgo principal es que la configuración de test headless o el pixel snap no se comporten igual en el editor y en CI, y se mitiga con el smoke test y la ejecución local documentada.
