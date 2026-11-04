# Proposal: visual-audio-level

## Why

El vertical slice es jugable, pero usa formas geométricas como placeholder, no tiene audio y el nivel se recorre en menos de un minuto. Para que se sienta como un arcade terminado hace falta identidad visual, sonido y más contenido.

## What Changes

- Integrar sprites pixel art de soldado, enemigos y escenario del pack **Fierce Soldier** de Vircon32 (CC-BY 4.0), con atribución.
- Generar tiles de terreno con variantes de superficie (hierba) y tierra, y actualizarlos al destruir.
- Añadir fondo parallax de cielo, montañas y selva, más decoraciones de palmeras y arbustos.
- Sustituir los placeholders de jugador, enemigos, POW, dummy, bala y salida por sprites.
- Añadir fuente pixel **Press Start 2P** (OFL) y un tema global para el HUD.
- Añadir screenshake de cámara en impactos y explosiones.
- Añadir SFX (disparo, escopeta, salto, impacto, explosión, rescate, muerte, victoria) y música de nivel en loop.
- Extender el nivel de 960 px a 1920 px con más plataformas, 10 enemigos y 4 prisioneros.

**Fuera de alcance:** nuevas mecánicas, jefes, múltiples niveles, guardado, voces y mezcla profesional.

## Capabilities

### New Capabilities

- `presentation`: sprites pixel art, tiles, fondo parallax, fuente/tema, HUD y screenshake.
- `audio`: SFX y música, con mapeo a eventos de juego.

### Modified Capabilities

- `level-flow`: el nivel jugable pasa a 1920 px con más enemigos y prisioneros.

## Impact

- **Nuevo:** `assets/sprites/`, `assets/background/`, `assets/audio/`, `assets/fonts/`, `assets/theme/`, `assets/third_party/`, `src/presentation/audio_manager.gd`, `scenes/background.tscn`, tests de presentación/audio.
- **Modificado:** escenas de jugador/enemigos/POW/dummy/bala/nivel, `src/world/destructible_terrain.gd`, `src/presentation/player_camera.gd`, `src/presentation/debug_session.gd`, `src/level/level.gd`, `project.godot`, README y tests.
- **Licencias:** Fierce Soldier (CC-BY 4.0, atribución obligatoria), Press Start 2P (OFL). Se incluyen textos de licencia y atribución.
- **Riesgo:** mezclar resoluciones de sprites; se normaliza todo a la escala interna 480×270 con nearest.
