# Tasks: visual-audio-level

## 1. Assets y licencias

- [x] 1.1 Integrar sprites de Fierce Soldier (CC-BY 4.0), generar POW/dummy/bala/bandera/tiles/fondos y descargar Press Start 2P (OFL); añadir textos de licencia y atribución. Verificación: todos los archivos existen y las licencias están en `assets/third_party` y `assets/fonts`.
- [x] 1.2 Sustituir el TileSet plano por un atlas de tierra/hierba y actualizar las variantes al destruir; añadir tests de atlas. Verificación: los tests de terreno pasan y la superficie cambia a hierba al destruir.

## 2. Sprites, fondo, tema y cámara

- [x] 2.1 Integrar sprites en jugador, grunt, kamikaze, POW, dummy, bala y salida; añadir animación por frames y flip/rotación según movimiento. Verificación: `test_visual_assets.gd` comprueba texturas no nulas y las escenas cargan.
- [x] 2.2 Añadir `scenes/background.tscn` con cielo, montañas y selva parallax, decoraciones de palmeras/arbustos en el nivel y el tema global Press Start 2P. Verificación: el nivel carga con fondo y fuente pixel, y los tests de tema pasan.
- [x] 2.3 Implementar `shake()` en `PlayerCamera` y conectarlo a impactos/explosiones; ampliar `test_player_camera.gd`. Verificación: el test de shake pasa y la cámara deja de sacudirse al expirar.

## 3. Audio

- [x] 3.1 Crear `src/presentation/audio_manager.gd` como autoload con catálogo de SFX, música en loop y API segura; escribir `tests/integration/test_audio_manager.gd`. Verificación: el test confirma catálogo, música y efecto desconocido sin errores.
- [x] 3.2 Conectar disparo, escopeta, salto, impacto, explosión, rescate, muerte, victoria y muerte de enemigo a sus SFX; iniciar música en el nivel. Verificación: los eventos de juego llaman al gestor y la suite pasa.

## 4. Nivel extendido

- [x] 4.1 Extender el nivel a 240 celdas (1920 px) con 8 plataformas, 10 enemigos y 4 POWs; mover la salida y ajustar la cámara. Actualizar `test_level.gd` y `README.md` con el nuevo contenido y las atribuciones. Verificación: los tests del nivel pasan y el nivel se recorre hasta la salida.

## 5. Cierre

- [x] 5.1 Borrar `.godot/`, ejecutar `./scripts/test.sh` desde cero y confirmar suite, `openspec validate --all --strict` y salida 0. Verificación: salida limpia sin `SCRIPT ERROR` ni fugas.

## Workflow follow-up

- Revisar el diff completo y confirmar licencias y atribuciones.
- Archivar el change con `/opsx-archive`.
