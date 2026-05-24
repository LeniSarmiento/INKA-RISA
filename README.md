# InkaRise EE3 - Prototype Trigonométrico v3

**Grupo 4**

Integrante registrado:
- Lenin David Mamani Sarmiento

> Proyecto en Godot 4.x basado en InkaRise, un juego 2D con estética andina donde el guerrero inca usa la Energía del Inti. Esta versión EE3 integra interacciones avanzadas con trigonometría y vectores.

---

## Objetivo del prototipo

Desarrollar una tercera versión jugable de InkaRise donde se apliquen conceptos trigonométricos y vectoriales para resolver un sistema de combate avanzado. El prototipo conserva el disparo angular de la EE2 y agrega tres mecánicas nuevas: rebote/ricochet, detección por rayo y homing/seek.

---

## Estructura del proyecto

```text
InkaRise_EE3_Interacciones_Avanzadas_Godot/
├─ assets/
│  └─ images/
├─ scenes/
│  ├─ Main.tscn
│  ├─ Player.tscn
│  ├─ Projectile.tscn
│  ├─ Target.tscn
│  ├─ RicochetProjectile.tscn
│  ├─ RicochetWall.tscn
│  ├─ LaserSensor.tscn
│  └─ HomingProjectile.tscn
├─ scripts/
│  ├─ Main.gd
│  ├─ Player.gd
│  ├─ Projectile.gd
│  ├─ Target.gd
│  ├─ Background.gd
│  ├─ RicochetProjectile.gd
│  ├─ RicochetWall.gd
│  ├─ LaserSensor.gd
│  └─ HomingProjectile.gd
├─ docs/
├─ records/
└─ project.godot
```

---

## Controles

| Tecla / acción | Función |
|---|---|
| Mouse | Apuntar con el ángulo θ |
| Click izquierdo | Disparo simple |
| Click derecho | Disparo spread con Δθ |
| A | Disparo ricochet/rebote |
| F | Rayo del Inti / RayCast2D equivalente |
| S | Disparo homing/seek |
| Q / E | Disminuir / aumentar Δθ |
| Z / X | Disminuir / aumentar cantidad de proyectiles |
| N | Avanzar nivel para demo |
| L | Guardar registro CSV runtime |
| R | Reiniciar juego |

---

## Mecánicas implementadas para EE3

### Mecánica A: Reflexión / Ricochet controlado

Se agregó un proyectil especial que rebota cuando colisiona con muros incas. El rebote utiliza la normal de la superficie:

```gdscript
velocity = velocity.bounce(normal)
```

Variables principales:
- `max_bounces`: cantidad máxima de rebotes.
- `bounce_count`: número de rebotes realizados.
- `last_collision_normal`: normal detectada en la colisión.
- `angle_after_deg`: ángulo de salida después del rebote.

Cómo probar:
1. Apunta hacia uno de los muros dorados.
2. Presiona `A`.
3. Observa cómo el proyectil cambia de dirección y el HUD muestra la normal.

---

### Mecánica B: Detección por rayo / RayCast2D equivalente

Se agregó el **Rayo del Inti**, que detecta objetivos en línea recta desde el jugador. La escena `LaserSensor.tscn` contiene un nodo `RayCast2D` como referencia visual/técnica, y el script calcula la intersección con objetivos usando distancia punto-segmento.

Variables principales:
- `ray_distance`: alcance del rayo.
- `ray_attempts`: cantidad de usos del rayo.
- `ray_hits`: detecciones correctas.
- `last_ray_result`: resultado mostrado en el HUD.

Cómo probar:
1. Apunta a un fragmento del Inti/enemigo.
2. Presiona `F`.
3. El rayo se activa y, si detecta el objetivo, aplica daño y registra el hit.

---

### Mecánica C: Direccionamiento hacia objetivo / Homing

Se agregó un proyectil que corrige su dirección hacia el objetivo más cercano. Usa interpolación angular con `lerp_angle` y un parámetro `turn_speed`.

```gdscript
new_angle = lerp_angle(current_angle, desired_angle, turn_speed * delta)
```

Variables principales:
- `turn_speed`: velocidad de corrección angular.
- `desired_angle_deg`: ángulo hacia el objetivo.
- `current_angle_deg`: ángulo actual del proyectil.
- `homing_hits`: impactos conseguidos con homing.

Cómo probar:
1. Apunta cerca de un objetivo, no necesariamente directo.
2. Presiona `S`.
3. El proyectil ajusta su trayectoria hacia el objetivo.

---

## Parámetros clave

| Parámetro | Uso |
|---|---|
| `theta_base_deg` | Ángulo base de apuntado |
| `delta_theta_deg` | Separación angular del spread |
| `projectile_speed` | Velocidad de proyectiles |
| `max_bounces` | Límite de rebotes del ricochet |
| `ray_distance` | Alcance del rayo |
| `turn_speed` | Velocidad de giro del homing |
| `hit_rate` | Porcentaje de acierto avanzado |

---

## Evidencia incluida

- `docs/nota_tecnica_ee3.md`: explicación matemática de dirección, rebote, rayo y homing.
- `docs/guion_video_demo_ee3.md`: guía para grabar el video demo de 60 a 90 segundos.
- `docs/texto_exposicion_ee3.md`: texto para explicar el proyecto.
- `records/registro_pruebas_ee3.csv`: 6 casos de prueba, 2 por mecánica.
- `records/variables_combate_avanzado_ee3.csv`: clasificación de variables por origen y formato.
- `records/limpieza_datos_ee3.csv`: evidencia antes/después de corrección de valores atípicos.

---

## Cómo abrir el proyecto

1. Descomprimir la carpeta.
2. Abrir Godot 4.x.
3. Seleccionar **Importar**.
4. Elegir `project.godot`.
5. Ejecutar con `F5`.

---

## Cómo exportar build

1. Ir a **Project > Export**.
2. Seleccionar Windows o Web.
3. Instalar plantillas de exportación si Godot lo solicita.
4. Exportar el ejecutable o versión web.

---

## Resumen de cumplimiento EE3

| Requisito | Estado |
|---|---|
| Ricochet con normal/reflexión | Implementado |
| RayCast2D o equivalente | Implementado |
| Homing/seek con turn_speed | Implementado |
| Integración en una escena jugable | Implementado |
| Registro de 6 pruebas | Incluido |
| Variables clasificadas | Incluido |
| Limpieza de datos | Incluido |
| Nota técnica 15-20 líneas | Incluida |
| Guion para video 60-90 s | Incluido |

## Intro / menú inicial agregado

Para mejorar la presentación del prototipo se agregó una escena de inicio:

- `scenes/MainMenu.tscn`: pantalla inicial del juego.
- `scripts/MainMenu.gd`: controla los botones del menú.
- `assets/images/menu_background_inka.png`: fondo visual inspirado en montañas andinas, templos y cultura inca.

Botones del menú:

- **INICIAR**: carga la escena principal `Main.tscn`.
- **LOGROS**: muestra logros relacionados con las mecánicas EE3: ricochet, Rayo del Inti, homing, niveles y métricas.

Controles adicionales:

- `Enter`: iniciar partida desde el menú.
- `L`: abrir/cerrar logros desde el menú.
- `Esc`: cerrar logros o volver al menú desde la partida.


## Actualización: Mapa de niveles y capas ambientales

Se agregó una escena de mapa antes del juego principal. El flujo ahora es:

```text
Menú inicial → Mapa del juego → Selección de nivel → Juego
```

Archivos principales:

- `scenes/LevelMap.tscn`
- `scripts/LevelMap.gd`
- `scripts/GameState.gd`
- `scripts/Background.gd` actualizado con capas por nivel

El fondo cambia según el nivel: inicio andino, ruinas incas, zona de rebotes, zona de habilidades y templo final. Esto refuerza la ambientación de InkaRise y hace más clara la progresión del prototipo EE3.
