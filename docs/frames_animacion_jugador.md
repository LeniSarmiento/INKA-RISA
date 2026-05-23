# Frames de animación del jugador — InkaRise EE3

Se agregaron frames visuales para mejorar la presentación del personaje durante el combate.

## Ruta de frames

`assets/images/player_frames/`

## Animación de disparo

Archivos:

- `shoot_00.png`
- `shoot_01.png`
- `shoot_02.png`
- `shoot_03.png`
- `shoot_04.png`
- `shoot_05.png`
- `shoot_spritesheet.png`

Uso en el juego:

- Se activa cuando el jugador dispara con click izquierdo.
- También se activa con disparo en abanico, rebote, rayo y guía.
- Refuerza visualmente la mecánica de ángulo θ y dirección del proyectil.

## Animación de daño

Archivos:

- `damage_00.png`
- `damage_01.png`
- `damage_02.png`
- `damage_03.png`
- `damage_04.png`
- `damage_spritesheet.png`

Uso en el juego:

- Se activa cuando el jugador pierde una vida.
- El personaje parpadea, se tiñe de rojo y muestra un efecto de impacto.
- Ayuda a que el usuario entienda que recibió daño.

## Código modificado

Archivo principal:

`scripts/Player.gd`

Funciones nuevas:

- `start_shoot_animation()`
- `pulse_damage()` mejorada
- `_get_action_texture()`

Archivo que llama las animaciones:

`scripts/Main.gd`

Se agregó el helper:

`_play_player_shoot_animation()`

Este helper se llama desde:

- disparo simple,
- disparo en abanico,
- rebote,
- rayo,
- guía.
