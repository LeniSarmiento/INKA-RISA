# Mapa de niveles y capas ambientales - InkaRise EE3

## Flujo implementado
Menú inicial → Mapa del juego → Selección de nivel → Escena principal.

## Archivos agregados
- `scenes/LevelMap.tscn`: escena del mapa.
- `scripts/LevelMap.gd`: dibuja el mapa, ruta de 10 niveles, zonas, paneles y selección con mouse/teclado.
- `scripts/GameState.gd`: guarda el nivel seleccionado para que `Main.gd` lo use al iniciar.

## Fondo por capas
Se actualizó `scripts/Background.gd` para dibujar capas ambientales según el nivel:
- cielo y nubes,
- montañas,
- ruinas incas,
- plataformas,
- vegetación,
- símbolos del Inti y efectos visuales.

## Zonas por nivel
- Nivel 1-2: inicio andino.
- Nivel 3-4: ruinas incas.
- Nivel 5-6: zona de rebotes.
- Nivel 7-8: zona de habilidades.
- Nivel 9-10: templo final / jefe.

## Controles
- Click en un nodo del mapa: iniciar ese nivel.
- Teclas 1-9 y 0: iniciar nivel 1-10.
- ESC: volver al menú.
