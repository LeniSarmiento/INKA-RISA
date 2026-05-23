# Intro / Menú inicial EE3

El menú inicial fue rediseñado con una interfaz inspirada en la cultura inca y en la Energía del Inti.

## Elementos implementados

- Fondo `assets/images/banner_run.jpg` con estética andina.
- Panel principal con título **INKA RISE**.
- Botón **INICIAR** para entrar a la escena principal del juego.
- Botón **INSTRUCCIONES** para mostrar u ocultar las mecánicas EE3.
- Panel lateral con las tres mecánicas avanzadas:
  - **A**: Rebote Andino / ricochet.
  - **F**: Rayo del Inti / detección por rayo.
  - **S**: Espíritu Guía / proyectil homing.
- Indicaciones de niveles, HUD y métricas.

## Flujo del juego

1. El proyecto carga primero `res://scenes/MainMenu.tscn`.
2. El jugador presiona **INICIAR** o **Enter**.
3. Godot cambia a `res://scenes/Main.tscn`.
4. El jugador prueba las mecánicas avanzadas dentro de la escena integrada.
