# Force

Run-and-gun arcade 2D con pixel art, inspirado en la energía de Broforce: movimiento rápido, apuntado libre, terreno destructible, rescates y explosiones.

El proyecto está en fase de **bootstrap**: todavía no hay gameplay. Esta base deja listo el motor, la configuración pixel-perfect, el mapa de entrada y la puerta de calidad SDD/TDD.

## Requisitos

- **Godot 4.7.2 stable** (build Linux x86_64).
- **OpenSpec CLI 1.14.2** o compatible.
- **GUT 9.7.1** ya vendorizado en `addons/gut/`; no hay que instalarlo.

La ruta del binario de Godot usada por los scripts es:

```text
/home/alejandro/godot/Godot_v4.7.2-stable_linux.x86_64
```

## Abrir el proyecto

```bash
/home/alejandro/godot/Godot_v4.7.2-stable_linux.x86_64 --path .
```

También puedes abrir `project.godot` desde el gestor de proyectos de Godot.

## Ejecutar el juego

```bash
/home/alejandro/godot/Godot_v4.7.2-stable_linux.x86_64 --path .
```

El juego arranca en `scenes/main_menu.tscn`, con opciones **Jugar**, **Opciones**, **Controles** y **Salir**. Desde el menú se puede alternar pantalla completa, cambiar el volumen maestro y consultar los controles. **Jugar** carga `scenes/level_01.tscn`, un nivel jugable de 3840 px con terreno destructible, plataformas, 40 enemigos, 8 prisioneros y una salida. Incluye sprites pixel art, fondo parallax, fuente pixel, screenshake, SFX y música en loop.

**Objetivo:** avanzar hasta la bandera de salida. Rescatar prisioneros da una vida extra, 500 puntos y un nuevo checkpoint. Los soldados enemigos disparan proyectiles; el jugador puede agacharse para esquivarlos o destruirlos con sus balas. Tiene 3 vidas, una barra de salud y reaparece en el último checkpoint al quedarse sin salud.

Controles:

- **A/D o flechas** mueven al jugador.
- **Espacio** salta (con coyote time y jump buffer).
- **S o flecha abajo** se agacha para esquivar disparos altos.
- **Ratón o stick derecho** apuntan en 360°; el arma rota con el apuntado y la cámara añade look-ahead.
- **Clic izquierdo o RT** dispara el rifle.
- **Esc** pausa o reanuda la partida.
- **R** reinicia el nivel con 3 vidas y 0 puntos.

En el menú inicial se navega con **flechas o gamepad**, se confirma con **Enter/A** y se vuelve con **Esc**.

`scenes/debug_session.tscn` se conserva como banco de pruebas: dummy, botones **Rifle**/**Shotgun**, **Lose life**, **Add 100**, **Restart** y **Explode**. `scenes/bootstrap.tscn` sigue siendo el fixture del smoke test de la fundación.

## Ejecutar la puerta de calidad

```bash
./scripts/test.sh
```

El script:

1. Importa el proyecto en headless.
2. Ejecuta toda la suite de GUT en `tests/`.
3. Ejecuta `openspec validate --all --strict`.
4. Devuelve código 0 solo si ambas partes pasan.

Si Godot está en otra ruta:

```bash
GODOT_BIN=/ruta/a/godot ./scripts/test.sh
```

Para ejecutar solo GUT:

```bash
/home/alejandro/godot/Godot_v4.7.2-stable_linux.x86_64 --headless --path . \
  -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

Para validar solo OpenSpec:

```bash
openspec validate --all --strict
```

## Estructura

```text
src/
  core/          Lógica pura (RefCounted, sin nodos ni autoloads)
  entities/      Escenas de jugador, enemigos, balas
  world/         Terreno, niveles, spawners
  presentation/  Cámara, VFX, HUD, audio
  autoload/      Event bus y sesión (solo glue)
tests/
  unit/          Pruebas de lógica pura
  integration/   Pruebas headless de escenas
  helpers/       Harness, inputs guionizados, fixtures
scenes/          Escenas de entrada y debug
assets/          Sprites, audio y fuentes
docs/adr/        Decisiones de arquitectura
scripts/         Automatización local
openspec/        Specs, changes y configuración SDD
```

Regla de dependencia: `src/core` no conoce nodos, `Input` global, autoloads, reloj de pared ni RNG global. Las dependencias se inyectan. El test `tests/unit/test_core_isolation.gd` lo verifica.

## Flujo SDD + TDD

Cada incremento se planifica como un change de OpenSpec:

```text
proposal → specs (delta) → design → tasks → apply → archive
```

Comandos habituales:

```text
/opsx-propose   Crear un change con todos sus artifacts
/opsx-apply     Implementar las tasks pendientes
/opsx-archive   Archivar el change y sincronizar specs
```

Durante `apply`, cada task se implementa con ciclo TDD:

1. Escribir el test que corresponde al escenario de la spec y verlo fallar.
2. Implementar lo mínimo para ponerlo en verde.
3. Refactorizar manteniendo la suite verde.
4. Marcar la task y ejecutar `./scripts/test.sh`.

## Configuración de presentación

- Resolución interna: **480×270**.
- Ventana inicial: **1440×810** (3×).
- Escalado entero, proporción conservada, filtro nearest y pixel snap.
- Renderer: `gl_compatibility`.
- Física: 60 ticks por segundo.

## Estado actual

- [x] Proyecto Godot y configuración pixel-perfect.
- [x] GUT 9.7.1 y comando único de calidad.
- [x] `InputMap` inicial para teclado, ratón y gamepad.
- [x] Guardia de aislamiento de `src/core`.
- [x] Smoke test de arranque.
- [x] Bucle de sesión: estados, vidas, puntuación, pausa y reinicio.
- [x] Jugador: movimiento, salto con coyote time/jump buffer, apuntado 360° y cámara.
- [x] Terreno destructible: celdas de 8 px, explosiones, tiles y colisión.
- [x] Combate: rifle, escopeta, balas con pooling, daño, retroceso e hitstop.
- [x] Enemigos, rescates, nivel jugable, HUD, victoria, game over y reinicio.
- [x] Supervivencia: enemigos a distancia, agacharse, proyectiles destructibles y barra de salud.
- [x] Vertical slice jugable de principio a fin.
- [x] Presentación: sprites pixel art, fondo parallax, fuente pixel y screenshake.
- [x] Audio: SFX de combate/rescate/muerte/victoria y música de nivel.
- [x] Nivel extendido a 1920 px con 10 enemigos y 4 POWs.

## Créditos y licencias

- **Fierce Soldier sprites** de Vircon32 (Carra), [OpenGameArt](https://opengameart.org/content/fierce-soldier-sprites), licencia **CC-BY 4.0**. Frames recortados y escalados; ver `assets/third_party/fierce_soldier/LICENSE.txt`.
- **Press Start 2P** de Cody "CodeMan38" Boisclair, licencia **OFL**; ver `assets/fonts/OFL.txt`.
- Tiles, fondos, POW, dummy, bala, bandera y audio generados para este proyecto.
