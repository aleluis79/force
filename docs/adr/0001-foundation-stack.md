# ADR 0001 — Base técnica del proyecto

- **Fecha:** 2026-11-03
- **Estado:** Aceptado
- **Contexto:** greenfield, vertical slice de un run-and-gun arcade 2D en pixel art.

## Contexto

Force necesita una base reproducible antes de escribir gameplay: motor, resolución, estrategia de pruebas y separación entre lógica y presentación. El repositorio parte solo con OpenSpec y no tiene proyecto Godot ni suite de tests. El binario de Godot está instalado fuera del repositorio, y el desarrollo debe poder verificarse sin abrir el editor.

## Decisiones

### 1. Godot 4.7.2 + GDScript tipado

Se usa Godot 4.7.2 stable con GDScript tipado. Para un arcade 2D, GDScript evita un pipeline de compilación, se integra con el editor y ofrece rendimiento suficiente para el presupuesto del slice.

**Alternativas:** C# (build más pesado, sin ventaja clara para 2D), Unity (fuera del stack elegido), Godot 4.6 (GUT 9.7.1 requiere 4.7.x).

**Consecuencias:** el proyecto depende de la versión 4.7.2; actualizar el motor requiere un change dedicado y revalidar GUT.

### 2. GUT 9.7.1 vendorizado

GUT se descarga desde el tag `v9.7.1` (rama `godot_4_7`) y se commitea completo en `addons/gut/`. No se usa submódulo para que un clon limpio pueda testearse sin pasos adicionales.

**Alternativas:** gdUnit4 (más mocking, innecesario para el slice), runner propio (reinventa reporte y filtros).

**Consecuencias:** el repositorio incluye el addon; las actualizaciones se hacen con un change explícito. GUT en headless termina solo y devuelve código de error si hay fallos.

### 3. Resolución interna 480×270 y escalado entero

La vista se renderiza a 480×270 y se escala a la ventana en múltiplos enteros, con filtro nearest, pixel snap y proporción conservada. La ventana inicial es 1440×810 (3×). El renderer es `gl_compatibility` para portabilidad.

**Alternativas:** 320×180 (píxeles más gruesos, menos espacio para HUD), 640×360 (diluye el look pixel art), escalado fraccional (bordes borrosos), `stretch/mode=viewport` (pixel perfect pero complica la UI).

**Consecuencias:** el arte debe diseñarse a 480×270; los tiles usan una grilla de 16 px y las celdas de destrucción 8 px. La configuración se verifica con `tests/unit/test_project_settings.gd`.

### 4. Lógica pura separada de los nodos

`src/core` contiene lógica `RefCounted` sin dependencias de `Node`, `Input` global, autoloads, reloj de pared ni RNG global. Las dependencias se inyectan. Los nodos de `entities`, `world` y `presentation` orquestan esa lógica.

**Alternativas:** lógica dentro de los nodos (tests lentos y acoplados), autoload global para todo (oculta dependencias y rompe determinismo).

**Consecuencias:** los tests unitarios son rápidos y deterministas; el test `tests/unit/test_core_isolation.gd` falla si se introduce una dependencia prohibida. `DeterministicRng` es la primera utilidad de `src/core` y establece el patrón.

### 5. Comando único de calidad

La puerta local es [`scripts/test.sh`](../../scripts/test.sh). El script importa el proyecto, ejecuta GUT headless, falla ante errores de script o suites vacías, y luego ejecuta `openspec validate --all --strict`.

**Alternativas:** dos comandos separados (fácil olvidar uno), pre-commit hook (no siempre instalado).

**Consecuencias:** el comando es la fuente de verdad local. La ruta del binario se puede sobreescribir con `GODOT_BIN`. La CI remota queda para un change posterior.

## Riesgos y mitigaciones

- **GUT y Godot 4.7.2:** se usa la versión upstream publicada para 4.7.x; el smoke test detecta fallos de arranque.
- **Pixel snap distinto entre editor y headless:** el smoke test valida instanciación y tamaño; la revisión visual del escalado es manual.
- **Errores de parseo silenciosos en GUT:** `scripts/test.sh` inspecciona la salida y falla ante `SCRIPT ERROR`, `Parse Error`, `GUT ERROR` o una suite vacía.
- **Dependencia de una ruta absoluta:** `GODOT_BIN` permite sobreescribirla.

## Referencias

- `project.godot` — configuración del proyecto.
- `tests/unit/test_project_settings.gd` — verificación de resolución y render.
- `tests/unit/test_core_isolation.gd` — guardia de arquitectura.
- `tests/integration/test_bootstrap_smoke.gd` — smoke test de arranque.
- `scripts/test.sh` — puerta de calidad local.
