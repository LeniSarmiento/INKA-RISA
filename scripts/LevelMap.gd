extends Node2D

const MAIN_SCENE_PATH: String = "res://scenes/Main.tscn"
const MENU_SCENE_PATH: String = "res://scenes/MainMenu.tscn"

var level_buttons: Array[Rect2] = []
var selected_level: int = 1
var hover_level: int = 0
var time_passed: float = 0.0

var level_positions: Array[Vector2] = [
	Vector2(155, 430), Vector2(285, 475), Vector2(415, 430), Vector2(548, 362), Vector2(690, 410),
	Vector2(828, 328), Vector2(955, 392), Vector2(1085, 292), Vector2(1150, 450), Vector2(1210, 320)
]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	queue_redraw()

func _process(delta: float) -> void:
	time_passed += delta
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	hover_level = 0
	for i in range(level_buttons.size()):
		if level_buttons[i].has_point(mouse_pos):
			hover_level = i + 1
			break
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file(MENU_SCENE_PATH)
		elif event.keycode >= KEY_1 and event.keycode <= KEY_9:
			_select_level(event.keycode - KEY_0)
		elif event.keycode == KEY_0:
			_select_level(10)

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for i in range(level_buttons.size()):
			if level_buttons[i].has_point(event.position):
				_select_level(i + 1)
				return

func _select_level(level: int) -> void:
	selected_level = clamp(level, 1, 10)
	var state: Node = get_node_or_null("/root/GameState")
	if is_instance_valid(state):
		state.set("selected_level", selected_level)
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)

func _draw() -> void:
	_draw_world_background()
	_draw_title_panel()
	_draw_routes()
	_draw_level_nodes()
	_draw_side_panel()
	_draw_bottom_panels()
	_draw_footer_help()

func _draw_world_background() -> void:
	var size: Vector2 = get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.03, 0.05, 0.07), true)
	# Cielo andino.
	draw_rect(Rect2(0, 0, size.x, 290), Color(0.18, 0.50, 0.74), true)
	# Sol del Inti.
	_draw_sun(Vector2(790, 110), 42.0)
	# Nubes suaves.
	for i in range(7):
		var x: float = fmod(time_passed * 10.0 + float(i) * 220.0, 1480.0) - 140.0
		var y: float = 72.0 + sin(time_passed * 0.6 + float(i)) * 9.0
		_draw_cloud(Vector2(x, y), 1.0 + float(i % 3) * 0.12)
	# Montañas lejanas.
	for i in range(8):
		var x2: float = float(i) * 210.0 - 130.0
		var peak: float = 145.0 + float(i % 3) * 34.0
		var mountain: PackedVector2Array = PackedVector2Array([
			Vector2(x2, 435), Vector2(x2 + 135, peak), Vector2(x2 + 305, 435)
		])
		draw_colored_polygon(mountain, Color(0.10, 0.22, 0.30, 0.82))
		var snow: PackedVector2Array = PackedVector2Array([
			Vector2(x2 + 135, peak), Vector2(x2 + 105, peak + 62), Vector2(x2 + 165, peak + 62)
		])
		draw_colored_polygon(snow, Color(0.85, 0.92, 0.92, 0.48))
	# Valles y neblina.
	for j in range(4):
		var yy: float = 330.0 + float(j) * 45.0
		draw_rect(Rect2(0, yy, size.x, 28), Color(0.55, 0.78, 0.84, 0.05 + float(j) * 0.015), true)
	# Ruinas laterales y plataformas flotantes.
	_draw_temple(Vector2(36, 305), 0.92, false)
	_draw_temple(Vector2(1080, 300), 0.82, true)
	_draw_floating_platform(Vector2(150, 464), 1.35)
	_draw_floating_platform(Vector2(415, 464), 1.05)
	_draw_floating_platform(Vector2(560, 398), 1.15)
	_draw_floating_platform(Vector2(700, 445), 1.10)
	_draw_floating_platform(Vector2(842, 363), 1.15)
	_draw_floating_platform(Vector2(1085, 330), 1.30)
	_draw_floating_platform(Vector2(1195, 487), 1.10)
	# Vegetación de primer plano.
	for k in range(22):
		var vx: float = 20.0 + float(k) * 60.0
		var vy: float = 620.0 + sin(float(k) * 1.7) * 12.0
		draw_circle(Vector2(vx, vy), 17.0, Color(0.07, 0.30, 0.13, 0.70))
	# Viñeta.
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, 0.17), true)

func _draw_sun(pos: Vector2, radius: float) -> void:
	draw_circle(pos, radius * 1.9, Color(1.0, 0.76, 0.12, 0.10))
	for i in range(16):
		var a: float = float(i) * TAU / 16.0
		draw_line(pos + Vector2(cos(a), sin(a)) * (radius + 4.0), pos + Vector2(cos(a), sin(a)) * (radius + 28.0), Color(1.0, 0.76, 0.12, 0.32), 3.0)
	draw_circle(pos, radius, Color(1.0, 0.72, 0.14, 0.72))
	draw_circle(pos, radius * 0.56, Color(1.0, 0.92, 0.35, 0.92))

func _draw_cloud(pos: Vector2, scale: float) -> void:
	var c: Color = Color(1.0, 1.0, 1.0, 0.36)
	draw_circle(pos, 22.0 * scale, c)
	draw_circle(pos + Vector2(28, -8) * scale, 30.0 * scale, c)
	draw_circle(pos + Vector2(62, 0) * scale, 21.0 * scale, c)
	draw_rect(Rect2(pos.x - 5.0 * scale, pos.y - 2.0 * scale, 75.0 * scale, 16.0 * scale), c, true)

func _draw_temple(pos: Vector2, scale: float, final_temple: bool) -> void:
	for i in range(6):
		var offset: float = float(i) * 12.0 * scale
		var w: float = (155.0 - float(i) * 18.0) * scale
		var h: float = 27.0 * scale
		var y: float = pos.y + float(i) * 29.0 * scale
		draw_rect(Rect2(pos.x + offset, y, w, h), Color(0.35, 0.25, 0.14, 0.92), true)
		draw_rect(Rect2(pos.x + offset, y, w, 4.0 * scale), Color(0.95, 0.67, 0.18, 0.72), true)
	var door: Rect2 = Rect2(pos.x + 55.0 * scale, pos.y + 145.0 * scale, 38.0 * scale, 60.0 * scale)
	draw_rect(door, Color(0.03, 0.02, 0.015, 0.90), true)
	if final_temple:
		draw_circle(pos + Vector2(76, 38) * scale, 34.0 * scale, Color(1.0, 0.05, 0.05, 0.22))
		draw_string(ThemeDB.fallback_font, pos + Vector2(44, 48) * scale, "JEFE", HORIZONTAL_ALIGNMENT_LEFT, -1, int(22 * scale), Color(1.0, 0.28, 0.18))

func _draw_floating_platform(center: Vector2, scale: float) -> void:
	var w: float = 132.0 * scale
	var h: float = 34.0 * scale
	var top_y: float = center.y
	draw_rect(Rect2(center.x - w / 2.0, top_y, w, h), Color(0.18, 0.12, 0.07, 0.92), true)
	draw_rect(Rect2(center.x - w / 2.0, top_y - 14.0, w, 18.0), Color(0.19, 0.42, 0.16, 0.95), true)
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(center.x - w / 2.0, top_y + h), Vector2(center.x + w / 2.0, top_y + h), Vector2(center.x + w * 0.25, top_y + h + 50.0 * scale), Vector2(center.x - w * 0.22, top_y + h + 55.0 * scale)
	])
	draw_colored_polygon(points, Color(0.20, 0.13, 0.09, 0.82))
	# Antorchas y adornos.
	if scale > 1.1:
		_draw_torch(center + Vector2(-42.0 * scale, -18.0))
		_draw_torch(center + Vector2(42.0 * scale, -18.0))

func _draw_torch(pos: Vector2) -> void:
	draw_rect(Rect2(pos.x - 3, pos.y, 6, 34), Color(0.35, 0.19, 0.07, 0.90), true)
	draw_circle(pos + Vector2(0, -7), 9.0, Color(1.0, 0.50, 0.05, 0.92))
	draw_circle(pos + Vector2(0, -7), 18.0, Color(1.0, 0.50, 0.05, 0.18))

func _draw_title_panel() -> void:
	_draw_panel(Rect2(455, 24, 370, 70), Color(0.01, 0.03, 0.04, 0.78), Color(1.0, 0.65, 0.10, 0.82), 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(505, 72), "MAPA DEL JUEGO", HORIZONTAL_ALIGNMENT_LEFT, -1, 36, Color(1.0, 0.73, 0.18))

func _draw_routes() -> void:
	for i in range(level_positions.size() - 1):
		var a: Vector2 = level_positions[i]
		var b: Vector2 = level_positions[i + 1]
		draw_line(a, b, Color(1.0, 0.75, 0.20, 0.75), 4.0)
		for j in range(6):
			var t: float = float(j) / 6.0
			var p: Vector2 = a.lerp(b, t)
			draw_circle(p, 4.2, Color(1.0, 0.93, 0.45, 0.95))

func _draw_level_nodes() -> void:
	level_buttons.clear()
	for i in range(level_positions.size()):
		var level: int = i + 1
		var p: Vector2 = level_positions[i]
		var node_rect: Rect2 = Rect2(p.x - 36, p.y - 36, 72, 72)
		level_buttons.append(node_rect)
		var color: Color = _get_level_color(level)
		var pulse: float = 1.0 + sin(time_passed * 3.0 + float(i)) * 0.08
		var outer_radius: float = 35.0 * pulse if hover_level == level else 31.0
		draw_circle(p, outer_radius + 8.0, Color(color.r, color.g, color.b, 0.20))
		draw_circle(p, outer_radius, Color(0.01, 0.03, 0.04, 0.95))
		draw_circle(p, outer_radius - 5.0, color)
		draw_circle(p, 15.0, Color(1.0, 0.86, 0.25, 0.95))
		draw_string(ThemeDB.fallback_font, p + Vector2(-9, 8), str(level), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.02, 0.02, 0.01))
		_draw_label_box(p + Vector2(-48, 44), _get_zone_name(level))

func _get_level_color(level: int) -> Color:
	if level <= 2:
		return Color(0.25, 0.95, 0.35, 0.95)
	if level <= 4:
		return Color(0.15, 0.76, 1.0, 0.95)
	if level <= 6:
		return Color(1.0, 0.62, 0.08, 0.95)
	if level <= 8:
		return Color(0.76, 0.28, 1.0, 0.95)
	return Color(1.0, 0.18, 0.15, 0.95)

func _get_zone_name(level: int) -> String:
	if level <= 2:
		return "INICIO"
	if level <= 4:
		return "RUINAS"
	if level <= 6:
		return "REBOTE"
	if level <= 8:
		return "HABILIDAD"
	return "JEFE"

func _draw_label_box(pos: Vector2, text: String) -> void:
	var rect: Rect2 = Rect2(pos.x, pos.y, 94, 24)
	draw_rect(rect, Color(0.01, 0.02, 0.025, 0.84), true)
	draw_rect(rect, Color(1.0, 0.65, 0.10, 0.55), false, 1.5)
	draw_string(ThemeDB.fallback_font, pos + Vector2(9, 17), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.88, 0.58))

func _draw_side_panel() -> void:
	# Panel de progreso compacto: se movió a la parte superior izquierda
	# para que el nodo "INICIO 1" quede visible y no se tape.
	var panel_rect: Rect2 = Rect2(22, 104, 345, 92)
	_draw_panel(panel_rect, Color(0.01, 0.025, 0.03, 0.82), Color(1.0, 0.65, 0.08, 0.55), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(43, 132), "PROGRESO GENERAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color(1.0, 0.78, 0.24))
	draw_rect(Rect2(215, 116, 95, 15), Color(0.02, 0.03, 0.03, 0.9), true)
	draw_rect(Rect2(215, 116, 28, 15), Color(1.0, 0.68, 0.08, 0.95), true)
	draw_string(ThemeDB.fallback_font, Vector2(318, 130), "20%", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.88, 0.42))
	var labels: Array[String] = ["INICIO", "DESAFÍO", "HABILIDAD", "REBOTE", "JEFE"]
	var colors: Array[Color] = [Color(0.25, 0.95, 0.35), Color(0.15, 0.76, 1.0), Color(0.76, 0.28, 1.0), Color(1.0, 0.62, 0.08), Color(1.0, 0.18, 0.15)]
	for i in range(labels.size()):
		var col: int = i % 3
		var row: int = int(i / 3)
		var x: float = 45.0 + float(col) * 106.0
		var y: float = 162.0 + float(row) * 22.0
		draw_circle(Vector2(x, y - 5.0), 7.0, colors[i])
		draw_string(ThemeDB.fallback_font, Vector2(x + 14.0, y), labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.95, 0.96, 0.92))

func _draw_bottom_panels() -> void:
	_draw_panel(Rect2(240, 590, 315, 95), Color(0.01, 0.025, 0.03, 0.82), Color(1.0, 0.65, 0.08, 0.45), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(265, 623), "CAPAS DEL ENTORNO", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1.0, 0.78, 0.24))
	var layer_names: Array[String] = ["Cielo", "Montañas", "Ruinas", "Plataformas", "Vegetación"]
	for i in range(layer_names.size()):
		draw_string(ThemeDB.fallback_font, Vector2(265 + float(i % 3) * 95, 650 + float(i / 3) * 24), "✓ " + layer_names[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.78, 1.0, 0.94))

	_draw_panel(Rect2(590, 590, 330, 95), Color(0.01, 0.025, 0.03, 0.82), Color(1.0, 0.65, 0.08, 0.45), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(615, 623), "VISTA PREVIA DEL NIVEL", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1.0, 0.78, 0.24))
	var preview_level: int = hover_level if hover_level > 0 else selected_level
	draw_string(ThemeDB.fallback_font, Vector2(615, 654), "Nivel seleccionado: " + str(preview_level), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color(0.90, 1.0, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(615, 677), "Zona: " + _get_zone_name(preview_level), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1.0, 0.88, 0.55))

	_draw_panel(Rect2(955, 590, 290, 95), Color(0.01, 0.025, 0.03, 0.82), Color(1.0, 0.65, 0.08, 0.45), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(980, 623), "ACCIÓN", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1.0, 0.78, 0.24))
	draw_string(ThemeDB.fallback_font, Vector2(980, 652), "Click en un nivel para jugar.", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.90, 1.0, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(980, 676), "ESC para volver al menú.", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1.0, 0.88, 0.55))

func _draw_footer_help() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(498, 710), "1-9 / 0: elegir nivel  •  ESC: volver", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.95, 0.95, 0.82))

func _draw_panel(rect: Rect2, fill: Color, border: Color, border_width: float) -> void:
	draw_rect(rect, fill, true)
	draw_rect(rect, border, false, border_width)

