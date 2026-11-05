# Proposal

## Why

El juego arranca directamente en el nivel, sin pantalla de inicio ni forma de ajustar opciones básicas antes de jugar. Un menú inicial mejora la presentación del vertical slice y permite elegir pantalla completa, volumen, consultar controles o salir sin entrar a la partida.

## What Changes

- Nueva escena de menú inicial como escena principal del proyecto.
- Botones **Jugar**, **Opciones**, **Controles** y **Salir**.
- Panel de opciones con:
  - Alternar pantalla completa/ventana.
  - Ciclar el volumen maestro.
  - Volver al menú.
- Panel de controles con el resumen de teclas y gamepad.
- Navegación por ratón, teclado y gamepad, con foco inicial y `Esc` para volver.
- El botón Jugar carga el nivel jugable existente.

**Fuera de alcance:** guardado persistente de opciones, remapeo de controles, selección de niveles, ajustes gráficos avanzados y música propia del menú.

## Capabilities

### New Capabilities

- `main-menu`: pantalla inicial, navegación, opciones y acceso al nivel.

### Modified Capabilities

<!-- Ninguna. -->

## Impact

- `project.godot`: escena principal.
- Nuevo `scenes/main_menu.tscn` y `src/presentation/main_menu.gd`.
- Reutilización del fondo y tema existentes.
- Tests de arranque, nodos del menú, navegación entre paneles y opciones.
