# Tasks: fix-facing-and-muzzle

## 1. Orientación y origen del disparo

- [x] 1.1 Escribir primero tests de orientación (jugador moviéndose, jugador quieto apuntando, grunt persiguiendo a la izquierda) y del origen de la bala (derecha, izquierda, arriba); implementar la prioridad de orientación en `Player._update_sprite`, el `flip_h` por dirección de persecución en `Grunt` y el muzzle del arma en `Player._fire`. Verificación: los tests pasan y las balas nacen por encima del centro del jugador.

## 2. Cierre

- [x] 2.1 Borrar `.godot/`, ejecutar `./scripts/test.sh` desde cero y confirmar suite, `openspec validate --all --strict` y salida 0. Verificación: salida limpia sin `SCRIPT ERROR` ni fugas.

## Workflow follow-up

- Revisar el cambio visual en el nivel.
- Archivar el change con `/opsx-archive`.
