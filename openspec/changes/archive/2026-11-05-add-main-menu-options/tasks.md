# Tasks

## 1. Menú y navegación

- [x] 1.1 Escribir primero tests de la escena de menú: nodos principales, paneles ocultos, foco inicial y cambio entre menú/opciones/controles. Implementar la escena y el script base. Verificación: los tests del menú pasan. Cubre: **Menú inicial** y **Panel de controles**.
- [x] 1.2 Escribir primero tests de navegación `Esc` para volver desde subpaneles. Implementar el manejo de `ui_cancel` y el retorno de foco. Verificación: los tests de navegación pasan. Cubre: **Navegación del menú**.

## 2. Opciones

- [x] 2.1 Escribir primero tests de las opciones: alternar pantalla completa, ciclar volumen y actualizar etiquetas. Implementar las acciones y el bus maestro. Verificación: los tests de opciones pasan. Cubre: **Opciones del menú**.
- [x] 2.2 Conectar Jugar con el nivel y Salir con el cierre del juego. Verificación: el menú referencia la escena jugable y el botón de salida invoca el cierre. Cubre: **Menú inicial**.

## 3. Integración

- [x] 3.1 Cambiar la escena principal a `main_menu.tscn`, actualizar el test de ajustes y el README. Verificación: el test de escena principal pasa y el juego arranca en el menú. Cubre: **Arranque del menú**.
- [x] 3.2 Ejecutar `./scripts/test.sh` y un smoke headless del menú y del nivel. Verificación: GUT y OpenSpec pasan; el menú arranca sin errores. Cubre: **Menú inicial**.
