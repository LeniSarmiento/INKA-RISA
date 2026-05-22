# Texto para exponer - InkaRise EE3

Buenos días profesor y compañeros. Somos el Grupo 4 y presentamos InkaRise EE3, una tercera versión del prototipo desarrollado en Godot. En esta versión mejoramos el sistema de combate aplicando trigonometría y vectores para resolver interacciones avanzadas.

Primero, el juego mantiene el apuntado con el ángulo θ. Este ángulo se calcula según la dirección entre el jugador y el mouse. Para mover el proyectil usamos coseno en el eje X y seno en el eje Y, formando el vector de dirección `(cos θ, sin θ)`.

La primera mecánica avanzada es el ricochet. Este proyectil rebota cuando choca con los muros incas. Para lograrlo usamos la normal de la superficie y aplicamos una reflexión vectorial. Así el proyectil cambia de dirección de forma coherente según el lado donde impacta.

La segunda mecánica es el Rayo del Inti, que funciona como RayCast2D o sensor de detección. El rayo sale desde el jugador, tiene un alcance definido y detecta si un objetivo está en su trayectoria. Si lo detecta, aplica daño y registra un impacto.

La tercera mecánica es el homing o seek. Este proyectil busca el objetivo más cercano y corrige su trayectoria usando interpolación angular. El parámetro principal es `turn_speed`, que controla qué tan rápido gira el proyectil hacia el objetivo.

También agregamos variables y métricas como ángulo, normal de colisión, número de rebotes, alcance del rayo, turn_speed, intentos, impactos y tasa de acierto. Estos datos aparecen en el HUD y también se registran para las pruebas.

Para la limpieza de datos, limitamos valores atípicos como rebotes negativos, alcance de rayo muy alto o turn_speed fuera de rango. Esto ayuda a que el prototipo sea más estable y comparable.

En conclusión, InkaRise EE3 demuestra cómo la trigonometría y los vectores pueden aplicarse dentro de un videojuego 2D para crear mecánicas de combate más completas, como rebote, detección por rayo y persecución de objetivos.
