# Texto para exponer - InkaRise v3

Buenos días, profesor y compañeros. Nuestro proyecto se llama InkaRise, un videojuego 2D inspirado en la cultura inca y en el uso de matemáticas aplicadas. En esta nueva versión mejoramos la visualización del juego integrando al personaje del guerrero inca y un escenario 2D con estilo de aventura. También agregamos un sistema de niveles del 1 al 10, donde cada nivel se vuelve más difícil.

Lo más importante del proyecto es el sistema de disparo trigonométrico. El jugador apunta con el mouse y el programa calcula el ángulo θ entre el personaje y el objetivo. A partir de ese ángulo usamos coseno para calcular el movimiento horizontal del proyectil y seno para calcular el movimiento vertical. Esto permite que el disparo funcione correctamente en diferentes direcciones.

También aplicamos un patrón angular llamado spread. En este patrón no sale un solo proyectil, sino varios proyectiles separados por un ángulo Δθ. Por ejemplo, si el jugador usa el disparo especial, los proyectiles se abren como un abanico de energía solar. Esto representa la Energía del Inti dentro del juego.

En cuanto a los niveles, la dificultad aumenta de manera progresiva. En los primeros niveles los objetivos son más grandes y lentos. En los niveles intermedios se vuelven más rápidos y aparecen con mayor frecuencia. En los niveles finales, los objetivos son más pequeños, tienen más resistencia y se necesita mejor precisión para avanzar.

También registramos métricas como intentos, impactos, fallos y precisión. Estas métricas aparecen en el HUD y nos permiten analizar si el sistema de disparo está funcionando correctamente. Además, aplicamos limpieza básica de datos, porque el juego corrige valores incorrectos como un Δθ negativo o una cantidad par de proyectiles.

En conclusión, InkaRise v3 combina diseño visual, cultura inca y trigonometría. El proyecto demuestra cómo el ángulo, el seno, el coseno y la variación angular pueden convertirse en una mecánica jugable dentro de Godot.
