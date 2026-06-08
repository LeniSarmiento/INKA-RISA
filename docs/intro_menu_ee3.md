# Intro / Menú inicial EE3

El menú inicial fue rediseñado con una interfaz inspirada en la cultura inca y en la Energía del Inti.

## Elementos implementados

- Fondo `assets/images/banner_run.jpg` con estética andina.
- Panel principal con título **INKA RISE**.
- Boton **INICIAR** para entrar al mapa de niveles.
- Botón **INSTRUCCIONES** para mostrar u ocultar las mecánicas EE3.
- Panel lateral con las tres mecánicas avanzadas:
  - **A**: Rebote Andino / ricochet.
  - **F**: Rayo del Inti / detección por rayo.
  - **S**: Espíritu Guía / proyectil homing.
- Indicaciones de niveles, HUD y métricas.

## Flujo del juego

1. El proyecto carga primero `res://scenes/Splash.tscn`.
2. La pantalla de presentacion cambia a `res://scenes/MainMenu.tscn`.
3. El jugador presiona **INICIAR** o **Enter**.
4. Godot cambia a `res://scenes/LevelMap.tscn`.
5. El jugador selecciona un nivel desbloqueado.
6. Godot carga `res://scenes/Main.tscn` con la dificultad del nivel elegido.
