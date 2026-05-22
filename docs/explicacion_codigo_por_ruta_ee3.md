# Explicación corta del código por ruta

## `scripts/Main.gd`
Controla la lógica general del juego: niveles, disparos, HUD, métricas y las tres mecánicas EE3. Desde aquí se crean los proyectiles ricochet, homing y el rayo.

## `scripts/RicochetProjectile.gd`
Controla el proyectil que rebota. Cuando toca un muro, obtiene la normal de la superficie y cambia su dirección con `bounce(normal)`.

## `scripts/RicochetWall.gd`
Representa los muros incas donde rebota el proyectil. También calcula la normal según el lado donde entra el proyectil.

## `scripts/LaserSensor.gd`
Controla el Rayo del Inti. Detecta si un objetivo está dentro de una línea de alcance y registra si hubo detección o no.

## `scripts/HomingProjectile.gd`
Controla el proyectil perseguidor. Busca el objetivo más cercano y corrige su ángulo usando `lerp_angle` y `turn_speed`.

## `scripts/Projectile.gd`
Mantiene el disparo normal y el disparo spread de la versión anterior.

## `scripts/Player.gd`
Dibuja al personaje inca, el aura solar y la línea de apuntado. También entrega la posición desde donde salen los disparos.

## `scripts/Target.gd`
Controla los objetivos o fragmentos del Inti. Se mueven, reciben daño y desaparecen cuando su vida llega a cero.

## `scripts/Background.gd`
Dibuja el escenario, el piso y la espiral Fibonacci decorativa.

## `records/`
Contiene tablas de variables, pruebas y limpieza de datos para sustentar la evidencia.

## `docs/`
Contiene la nota técnica, guion de video, checklist y texto de exposición.
