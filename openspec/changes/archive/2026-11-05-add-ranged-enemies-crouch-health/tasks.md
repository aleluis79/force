# Tasks

## 1. Entrada de agacharse

- [x] 1.1 Escribir primero tests de `InputSource` y `InputMap` para la acción `crouch` (teclado y gamepad); añadir la acción al proyecto y a las implementaciones de entrada. Verificación: `test_input_map.gd` y `test_input_source.gd` pasan. Cubre: **Entrada de agacharse**.
- [x] 1.2 Extender la fuente de entrada guionizada usada por tests y actualizar la documentación de controles en `README.md`. Verificación: los tests de integración pueden inyectar agacharse y la documentación lista la tecla/control. Cubre: **Entrada de agacharse**.

## 2. Salud e invulnerabilidad del jugador

- [x] 2.1 Escribir primero tests de integración para salud del jugador: recibir daño, no bajar de 0, muerte única y emisión de salud. Implementar `Health` en `Player` y la señal de salud. Verificación: los tests de daño y muerte del jugador pasan. Cubre: **Salud del jugador**.
- [x] 2.2 Escribir primero tests de invulnerabilidad breve tras impacto y al reaparecer; implementar el temporizador compartido y la restauración de salud al reaparecer. Verificación: solo el primer impacto de una ventana descuenta salud y la reaparición vuelve al máximo. Cubre: **Invulnerabilidad tras recibir daño**.
- [x] 2.3 Actualizar tests existentes que asumían muerte de un golpe (jugador, enemigos y nivel) para aplicar daño letal explícito o comprobar reducción de salud. Verificación: la suite previa sigue en verde sin perder cobertura. Cubre: **Salud del jugador** y **Muerte y reaparición**.

## 3. Agacharse y movimiento agachado

- [x] 3.1 Escribir primero tests de integración para el ciclo agacharse/soltar: altura de colisión reducida, pies estables y restauración al soltar. Implementar el cambio de shape duplicado en `Player`. Verificación: los tests de colisión agachada pasan. Cubre: **Agacharse**.
- [x] 3.2 Escribir primero un test de velocidad reducida mientras está agachado; implementar el factor de movimiento agachado. Verificación: la velocidad horizontal agachada es menor que la máxima de pie. Cubre: **Movimiento agachado**.
- [x] 3.3 Escribir primero un test que verifique el cambio a una textura de agachado dedicada sin escalar el sprite; generar la pose y conectar el cambio de textura y hombro del arma. Verificación: al agacharse cambia la textura, la cabeza no se deforma y el cuerpo usa escala 1. Cubre: **Pose legible**.

## 4. Proyectiles enemigos

- [x] 4.1 Escribir primero tests del proyectil enemigo: avanza, daña al jugador, desaparece al impactar y no destruye terreno; implementar la entidad de proyectil enemigo. Verificación: los tests del proyectil pasan. Cubre: **Proyectiles enemigos destructibles**.
- [x] 4.2 Escribir primero tests de disparo enemigo: disparo dentro de rango, cadencia limitada, sin disparo fuera de rango y cese al morir; implementar el ataque a distancia del soldado. Verificación: los tests de IA de disparo pasan. Cubre: **Soldado con ataque a distancia**.
- [x] 4.3 Escribir primero un test donde una bala del jugador intercepta y destruye un proyectil enemigo; ampliar la máscara de las balas del jugador y conectar el feedback existente. Verificación: el proyectil enemigo desaparece antes de tocar al jugador. Cubre: **Proyectiles enemigos destructibles**.
- [x] 4.4 Escribir primero un test funcional de esquiva: un disparo a la altura del torso impacta de pie pero pasa sobre el jugador agachado. Verificación: la salud cambia solo en el caso de pie. Cubre: **Agacharse** y **Soldado con ataque a distancia**.

## 5. HUD de salud

- [x] 5.1 Escribir primero un test del nivel que verifique la barra de salud, su valor máximo y su actualización al recibir daño y al reaparecer; añadir la barra al HUD y conectarla a la señal del jugador. Verificación: los tests del HUD pasan. Cubre: **Barra de salud en el HUD**.
- [x] 5.2 Actualizar el HUD/estilos y la documentación de la barra si hace falta, manteniendo el tema pixel y la legibilidad a 480×270. Verificación: el nivel carga sin errores y la barra se lee en el HUD. Cubre: **Barra de salud en el HUD**.

## 6. Integración y cierre

- [x] 6.1 Ejecutar `./scripts/test.sh` completo y corregir cualquier regresión de puntería, colisiones o balance entre sistemas. Verificación: GUT y `openspec validate --all --strict` pasan.
- [x] 6.2 Hacer una pasada de juego del nivel: recibir disparos, agacharse, destruir proyectiles y comprobar la barra de salud; ajustar constantes si la lectura es deficiente. Verificación: el flujo se completa sin errores en consola.

## Workflow follow-up

- Revisar los artefactos de este change con el usuario.
- Archivar el change y sincronizar las specs principales cuando la implementación esté verificada.
