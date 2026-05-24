# Cambios: mapa visible y tablas de rebote móviles

## Mapa de niveles
Se movió el panel de progreso a la parte superior izquierda y se redujo su tamaño para que el nodo **Inicio 1** se vea completo en el mapa.

## Tablas de rebote
Las superficies de ricochet ahora tienen movimiento:

- Tabla vertical: movimiento arriba/abajo.
- Tabla horizontal: movimiento izquierda/derecha.
- Tabla final: movimiento arriba/abajo más rápido.

Esto permite que el jugador use las tablas como apoyo para redirigir los proyectiles y demostrar mejor la reflexión con normal, uno de los requisitos de la Evidencia 3.

## Archivos modificados

- `scripts/LevelMap.gd`
- `scripts/RicochetWall.gd`
- `scripts/Main.gd`
