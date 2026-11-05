# Tasks

## 1. Plataformas y alcanzabilidad

- [x] 1.1 Escribir primero tests de geometría de plataformas: 25+, sin solapes, fila superior sólida, fila superior libre y todas alcanzables desde el suelo con la cota de salto. Implementar el patrón de 480 celdas. Verificación: los tests de usabilidad pasan. Cubre: **Plataformas usables** y **Nivel jugable**.
- [x] 1.2 Escribir primero un test funcional que deje caer al jugador sobre una plataforma alta y compruebe que aterriza. Verificación: el jugador queda apoyado sobre la plataforma. Cubre: **Aterrizaje real**.

## 2. Contenido extendido

- [x] 2.1 Escribir primero tests de contenido: ancho de 3840 px, 30+ enemigos, 8 POWs y salida después de 3700 px. Implementar los spawns data-driven, mover la salida y limpiar los nodos manuales del `.tscn`. Verificación: los tests de carga y conteo pasan. Cubre: **Nivel jugable**.
- [x] 2.2 Verificar que los enemigos sobre plataformas y en suelo aparecen en posiciones válidas y que los POWs conservan nombres accesibles para depuración. Verificación: los tests de rescate y muerte enemiga siguen pasando. Cubre: **Nivel jugable**.

## 3. Presión de disparo

- [x] 3.1 Escribir primero un test de cadencia repetida: un soldado en rango dispara un segundo proyectil tras su intervalo. Ajustar cadencia y rango para el nivel extendido. Verificación: el test de ráfaga pasa sin degradar los tests de rango/cadencia existentes. Cubre: **Nivel jugable**.

## 4. Integración

- [x] 4.1 Ejecutar `./scripts/test.sh` completo y corregir regresiones de cámara, salida, rescates y combate. Verificación: GUT y `openspec validate --all --strict` pasan.
- [x] 4.2 Smoke headless del nivel extendido para detectar errores de spawn, colisiones o proyectiles. Verificación: el nivel corre sin errores de gameplay en consola.
