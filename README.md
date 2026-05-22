# InkaRise v3 - Prototype Trigonométrico con niveles 1 al 10

## Descripción
**InkaRise** es un prototipo 2D hecho en Godot donde el jugador controla a un guerrero inca que usa la Energía del Inti para disparar proyectiles. Esta versión mejora el proyecto con:

- Personaje visual integrado desde la lámina de referencia del guerrero inca.
- Fondo 2D estilo videojuego/plataforma.
- Sistema de disparo con ángulo **θ**.
- Proyectil calculado con **cos(θ)** y **sin(θ)**.
- Patrón angular tipo **spread** controlado por **Δθ**.
- Sistema de niveles del **1 al 10**, aumentando la dificultad.
- HUD con variables, métricas y precisión.
- Registro CSV para evidenciar pruebas y limpieza de datos.

## Controles

| Acción | Control |
|---|---|
| Apuntar | Mover el mouse |
| Disparo simple | Click izquierdo |
| Disparo en patrón angular / spread | Click derecho |
| Disminuir Δθ | Q |
| Aumentar Δθ | E |
| Disminuir cantidad de proyectiles | Z |
| Aumentar cantidad de proyectiles | X |
| Guardar registro CSV en tiempo real | L |
| Reiniciar juego | R |
| Pasar de nivel para demo rápida | N |

## Mecánica trigonométrica aplicada

El ángulo base **θ** se obtiene según la dirección entre la posición del jugador y la posición del mouse.

```text
dirección = mouse - jugador
θ = dirección.angle()
```

Luego el proyectil se mueve usando componentes trigonométricas:

```text
Δx = cos(θ) * velocidad
Δy = sin(θ) * velocidad
```

Para el patrón angular, se generan varios proyectiles alrededor del ángulo base:

```text
ángulo_proyectil = θ + offset * Δθ
```

De esta manera, el disparo no depende de una dirección fija, sino de una regla matemática controlable.

## Niveles del 1 al 10

Cada nivel aumenta la dificultad mediante cuatro factores principales:

| Nivel | Cambios principales |
|---|---|
| 1-3 | Objetivos grandes, lentos y con poca cantidad en pantalla. |
| 4-5 | Aumenta la cantidad de proyectiles del spread y la velocidad de los objetivos. |
| 6-8 | Los objetivos tienen más vida, son más pequeños y aparecen más rápido. |
| 9-10 | Máxima dificultad: objetivos rápidos, resistentes y menor margen de precisión. |

## Variables y métricas del sistema

| Variable | Origen | Formato | Uso |
|---|---|---|---|
| θ | Entrada/estado | Numérico | Define la dirección del disparo. |
| Δθ | Parámetro | Numérico | Controla la separación angular del spread. |
| cantidad_proyectiles | Parámetro | Numérico | Define cuántos proyectiles salen en el patrón. |
| velocidad_proyectil | Parámetro | Numérico | Controla el desplazamiento del proyectil. |
| cooldown | Parámetro | Numérico | Tiempo de espera entre disparos. |
| nivel | Estado | Numérico | Indica la dificultad actual. |
| intentos | Resultado | Numérico | Cantidad de disparos realizados. |
| impactos | Resultado | Numérico | Objetivos destruidos. |
| precisión | Resultado | Numérico | Porcentaje de acierto. |

## Limpieza de datos implementada

El juego corrige valores inconsistentes del patrón angular:

- Si **Δθ** está vacío o no es válido, se reemplaza por un valor seguro.
- Si **Δθ** es negativo, se corrige a 0°.
- Si **Δθ** supera el máximo, se limita a 35°.
- La cantidad de proyectiles se mantiene impar para que el patrón tenga un proyectil central.
- La cantidad de proyectiles se limita entre 1 y 9.

## Archivos principales

```text
assets/images/          Imágenes del personaje y fondos.
scenes/Main.tscn        Escena principal.
scenes/Player.tscn      Escena del jugador.
scenes/Projectile.tscn  Escena del proyectil.
scenes/Target.tscn      Escena de los objetivos.
scripts/Main.gd         Lógica de niveles, métricas, disparo y HUD.
scripts/Player.gd       Personaje, apuntado y visualización.
scripts/Projectile.gd   Movimiento trigonométrico del proyectil.
scripts/Target.gd       Objetivos, vida, velocidad y dificultad.
records/                Mini-registro de datos.
docs/                   Nota técnica y texto de exposición.
```

## Cómo abrir en Godot

1. Descomprime el ZIP.
2. Abre Godot.
3. Selecciona **Importar**.
4. Elige la carpeta `InkaRise_v3_Niveles_Godot`.
5. Abre el archivo `project.godot`.
6. Ejecuta con **F5**.

## Recomendación para el video demo

Mostrar en 45 a 60 segundos:

1. El personaje y la visualización mejorada.
2. Apuntado hacia distintas direcciones.
3. Disparo simple en varios ángulos.
4. Disparo spread con Δθ.
5. Cambio de dificultad entre niveles usando la tecla N.
6. HUD con métricas de intentos, impactos y precisión.
