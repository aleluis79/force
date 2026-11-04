# Design: visual-audio-level

## Context

El slice es jugable con placeholders. Se incorpora arte libre y audio generado, y se duplica el largo del nivel. Ver `proposal.md` y las specs de `presentation`, `audio` y `level-flow`.

## Goals / Non-Goals

**Goals:** sprites pixel art, tiles con hierba/tierra, fondo parallax, fuente pixel, screenshake, SFX/música y nivel de 1920 px.

**Non-Goals:** nuevas mecánicas, jefes, más niveles, voces, mezcla profesional.

## Decisions

### D1. Arte libre con licencia y assets generados

- **Fierce Soldier** de Vircon32 (OpenGameArt, CC-BY 4.0): soldado, enemigos y decoración. Se recortan frames y se escalan a la resolución interna. Atribución en `assets/third_party/fierce_soldier/LICENSE.txt` y README.
- **Press Start 2P** (Google Fonts, OFL): fuente del HUD. Licencia en `assets/fonts/OFL.txt`.
- **Generados**: tiles de terreno, POW, dummy, bala, bandera y fondos. Se generan con un script Pillow fuera del repo y se commitean los PNG finales.

Los sprites se normalizan a la escala 480×270: jugador 28×42 (6 frames), grunt 28×42 (2), kamikaze 32×14 (2), POW 20×28 (2), dummy 16×24, bala 8×3, bandera 24×32.

### D2. Terreno con atlas de dos tiles

El `TileSet` usa `assets/sprites/terrain.png` (16×8) con dos tiles 8×8: tierra y hierba. `_tile_for(cell)` elige hierba si la celda superior no es sólida. `_refresh_cell` actualiza el tile; tras una explosión se refrescan las celdas vecinas para que la nueva superficie cambie a hierba.

### D3. Fondo parallax y decoración

`scenes/background.tscn` usa `ParallaxBackground` con:

- Cielo fijo (`motion_scale = 0`).
- Montañas lejanas (`0.2`, mirroring 480).
- Selva cercana (`0.5`, mirroring 480).

El nivel añade palmeras, arbustos y plantas con `z_index` negativo y `modulate` oscuro para profundidad.

### D4. Tema y HUD

`assets/theme/game_theme.tres` define `PressStart2P` como fuente por defecto a tamaño 8. `project.godot` lo configura en `gui/theme/custom`. El mensaje central usa tamaño 12. Las etiquetas y botones heredan el tema.

### D5. Screenshake

`PlayerCamera` añade `shake(strength, duration)`, un temporizador y un offset aleatorio decreciente. El nivel conecta impactos de bala y explosiones de terreno. Los tests verifican que `is_shaking()` se activa y expira.

### D6. AudioManager

Autoload `AudioManager` (`src/presentation/audio_manager.gd`):

- 8 `AudioStreamPlayer` para SFX en round-robin.
- `AudioStreamPlayer` de música con loop por `finished`.
- Diccionario de WAVs: shoot, shotgun, jump, hit, explosion, pickup, death, victory, hurt.
- API `play_sfx(name)`, `play_music()`, `has_sfx(name)`, `has_music()`.

Eventos conectados:

- Disparo/salto → Player.
- Explosión → DestructibleTerrain.
- Impacto → nivel/debug (además de hitstop y shake).
- Rescate, muerte, victoria y muerte de enemigo → nivel.

### D7. Nivel extendido

`level.gd` reconstruye el terreno a 240×34 celdas (1920×272 px) con 8 plataformas. La escena añade 6 grunts, 4 kamikazes, 4 POWs y mueve la salida a `(1840, 200)`. La cámara limita a 1920.

### D8. Tests

- `test_visual_assets.gd`: texturas no nulas, sprites en escenas, tema/fuente, atlas de terreno, fondo.
- `test_audio_manager.gd`: catálogo de SFX, música y efecto desconocido.
- `test_player_camera.gd`: shake.
- `test_level.gd`: ancho 240, 10 enemigos, 4 POWs, salida.
- Tests existentes actualizados.

## Risks / Trade-offs

| Riesgo | Mitigación |
|---|---|
| Mezcla de resoluciones de sprites | Normalización a 480×270 y nearest |
| Sprites externos con licencia | Atribución y licencia incluidas |
| Sonido molesto o demasiado fuerte | Volumen bajo y players separados; ajuste manual |
| El nivel largo aburre | Plataformas, enemigos y POWs distribuidos |
| La fuente pixel reduce legibilidad | Tamaño 8 y mensajes a 12 |
| El shake marea | Duración corta e intensidad baja |

## Migration Plan

No hay datos. Se añaden assets y se actualizan escenas. Rollback: restaurar escenas y eliminar assets nuevos.

## Open Questions

Ninguna que afecte al alcance. La mezcla fina de audio y balance se ajusta en playtest.
