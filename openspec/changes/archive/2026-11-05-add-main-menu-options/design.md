# Design

## Context

Ver `proposal.md` y el delta de `main-menu`. El proyecto ya tiene fondo parallax, tema pixel, audio con bus maestro y un nivel jugable independiente. La escena principal actual es `level_01.tscn`.

## Goals / Non-Goals

**Goals:**

- Menú operativo con ratón, teclado y gamepad.
- Opciones inmediatas sin persistencia ni archivos de configuración.
- Reutilizar fondo, tema y fuente existentes.
- Mantener el nivel jugable intacto.

**Non-Goals:**

- Guardado de preferencias entre sesiones.
- Remapeo de teclas o sliders gráficos.
- Menú de pausa dentro del nivel.

## Decisions

### 1. Escena Control con paneles conmutables

`main_menu.tscn` es un `Control` con tres paneles (`MainPanel`, `OptionsPanel`, `ControlsPanel`) dentro de `CenterContainer`. Solo uno está visible a la vez. El script cambia visibilidad y mueve el foco al primer botón del panel.

- **Alternativa descartada:** tres escenas separadas. Más navegación y estado compartido innecesario para cuatro botones.
- **Alternativa descartada:** un único panel con un Label que cambia texto. Peor jerarquía visual y de foco.

### 2. Opciones aplicadas directamente

Pantalla completa usa `DisplayServer.window_set_mode`; volumen usa el bus maestro de `AudioServer` y cicla 100/75/50/25/0 %. No se guarda estado en disco.

- **Alternativa descartada:** `ConfigFile` persistente. Añade migración y tests de IO fuera del alcance del slice.
- **Alternativa descartada:** sliders. Los botones que ciclan valores son más legibles a 480×270 y fáciles de operar con gamepad.

### 3. Fondo y tema reutilizados

La escena instancia `background.tscn` y aplica `game_theme.tres` al root. El título usa tamaño mayor; los botones usan el tema pixel.

- **Alternativa descartada:** arte nuevo de menú. No aporta al objetivo y rompe la reutilización.

### 4. Navegación con acciones UI integradas

Se usan las acciones `ui_accept`, `ui_focus_next` y `ui_cancel` estándar de Godot. Jugar recibe foco al arrancar. `Esc` vuelve al panel principal si hay un subpanel abierto.

- **Alternativa descartada:** InputMap propio para el menú. Duplica bindings que Godot ya resuelve para teclado y gamepad.

## Risks / Trade-offs

- [Cambiar a pantalla completa en headless puede ser inestable] → El test verifica el estado interno y la etiqueta; la llamada real se tolera en el entorno de test.
- [El volumen 0 % silencia también efectos de UI] → Es el comportamiento esperado del bus maestro.
- [Cambiar la escena principal rompe tests que asumían el nivel] → Se actualiza el test de ajustes del proyecto y se mantiene el nivel cargable directamente.
- [Foco automático poco predecible con gamepad] → Se asigna foco explícito al abrir cada panel.

## Migration Plan

- Añadir la escena y el script.
- Cambiar `application/run/main_scene` a `main_menu.tscn`.
- Actualizar tests y README.
- Rollback: restaurar `level_01.tscn` como escena principal y eliminar la escena de menú.

## Open Questions

Ninguna que afecte a specs, alcance o tareas.
